import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { v4 as uuidv4 } from "uuid";
import {
  requireAuth,
  db,
  FieldValue,
  forbidden,
  notFound,
  badRequest,
  success,
} from "../utils/helpers";
import { validate, createRoundSchema } from "../utils/validation";

export const createFundingRound = functions.https.onCall(
  async (data, context) => {
    const uid = requireAuth(context);

    const input = validate(createRoundSchema, data);

    const startupDoc = await db
      .collection("startups")
      .doc(input.startupId)
      .get();

    if (!startupDoc.exists) notFound("Startup not found");

    const startup = startupDoc.data()!;

    if (startup.founderId !== uid) {
      forbidden("Only the startup founder can create funding rounds");
    }

    if (startup.status !== "approved") {
      badRequest("Startup must be approved before creating funding rounds");
    }

    const deadline = new Date(input.deadline);
    if (isNaN(deadline.getTime()) || deadline <= new Date()) {
      badRequest("Deadline must be a valid future date");
    }

    if (input.minInvestment >= input.targetAmount) {
      badRequest("Minimum investment must be less than target amount");
    }

    const roundId = uuidv4();

    await db.collection("fundingRounds").doc(roundId).set({
      id: roundId,
      startupId: input.startupId,
      startupName: startup.name as string,
      founderId: uid,
      title: input.title,
      targetAmount: input.targetAmount,
      raisedAmount: 0,
      minInvestment: input.minInvestment,
      status: "open",
      deadline: admin.firestore.Timestamp.fromDate(deadline),
      investorCount: 0,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });

    functions.logger.info(
      `Funding round ${roundId} created for startup ${input.startupId}`
    );

    return success({ roundId }, "Funding round created successfully");
  }
);