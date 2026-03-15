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
import { validate, makeInvestmentSchema } from "../utils/validation";

export const makeInvestment = functions.https.onCall(async (data, context) => {
  const uid = requireAuth(context);

  const claimRole = context.auth!.token.role as string | undefined;
  let userRole = claimRole;

  if (!userRole) {
    const userDoc = await db.collection("users").doc(uid).get();
    userRole = userDoc.data()?.role as string | undefined;
  }

  if (userRole === "entrepreneur") {
    forbidden("Founders cannot invest. Use an investor account.");
  }

  const input = validate(makeInvestmentSchema, data);
  const investmentId = input.investmentId ?? uuidv4();

  await db.runTransaction(async (tx: admin.firestore.Transaction) => {
    const roundRef = db.collection("fundingRounds").doc(input.roundId);
    const roundDoc = await tx.get(roundRef);

    if (!roundDoc.exists) notFound("Funding round not found");

    const round = roundDoc.data()!;

    if (round.status !== "open") {
      badRequest("This funding round is not open for investment");
    }

    const deadline = (round.deadline as admin.firestore.Timestamp).toDate();
    if (deadline < new Date()) {
      badRequest("This funding round has expired");
    }

    if (input.amount < (round.minInvestment as number)) {
      badRequest(
        `Minimum investment is $${round.minInvestment as number}. You provided $${input.amount}`
      );
    }

    const remaining =
      (round.targetAmount as number) - (round.raisedAmount as number);
    if (input.amount > remaining) {
      badRequest(`Maximum available is $${remaining}. Round is almost full.`);
    }

    const userRef = db.collection("users").doc(uid);
    const userDoc = await tx.get(userRef);
    const investorName =
      (userDoc.data()?.displayName as string | undefined) ?? "Investor";

    const investmentRef = db.collection("investments").doc(investmentId);

    tx.set(investmentRef, {
      id: investmentId,
      investorId: uid,
      investorName,
      startupId: input.startupId,
      startupName: round.startupName as string,
      roundId: input.roundId,
      roundTitle: round.title as string,
      amount: input.amount,
      status: "confirmed",
      blockchainTxHash: null,
      createdAt: FieldValue.serverTimestamp(),
    });

    const newRaised = (round.raisedAmount as number) + input.amount;
    const newInvestorCount = (round.investorCount as number) + 1;
    const shouldClose = newRaised >= (round.targetAmount as number);

    tx.update(roundRef, {
      raisedAmount: newRaised,
      investorCount: newInvestorCount,
      status: shouldClose ? "closed" : "open",
      updatedAt: FieldValue.serverTimestamp(),
    });
  });

  functions.logger.info(
    `Investment ${investmentId}: $${input.amount} by ${uid} in round ${input.roundId}`
  );

  return success(
    { investmentId, amount: input.amount },
    "Investment confirmed successfully"
  );
});