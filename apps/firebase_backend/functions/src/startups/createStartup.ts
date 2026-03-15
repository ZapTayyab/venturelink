import * as functions from "firebase-functions";
import { v4 as uuidv4 } from "uuid";
import {
  requireAuth,
  db,
  FieldValue,
  forbidden,
  success,
} from "../utils/helpers";
import { validate, createStartupSchema } from "../utils/validation";

export const createStartup = functions.https.onCall(async (data, context) => {
  // 1. Auth check
  const uid = requireAuth(context);

  // 2. Role check — only entrepreneurs can create startups
  const role = context.auth!.token.role as string | undefined;

  // Also check Firestore role as fallback (custom claims may not be set yet)
  let userRole = role;
  if (!userRole) {
    const userDoc = await db.collection("users").doc(uid).get();
    userRole = userDoc.data()?.role;
  }

  if (userRole !== "entrepreneur") {
    // Get user data from Firestore as final fallback
    const userDoc = await db.collection("users").doc(uid).get();
    if (userDoc.data()?.role !== "entrepreneur") {
      forbidden("Only founders can create startups");
    }
  }

  // 3. Validate input
  const input = validate(createStartupSchema, data);

  // 4. Get founder name
  const userDoc = await db.collection("users").doc(uid).get();
  const founderName = userDoc.data()?.displayName ?? "Unknown";

  // 5. Check duplicate name
  const existing = await db
    .collection("startups")
    .where("founderId", "==", uid)
    .where("name", "==", input.name)
    .limit(1)
    .get();

  if (!existing.empty) {
    throw new functions.https.HttpsError(
      "already-exists",
      "You already have a startup with this name"
    );
  }

  // 6. Create startup document
  const startupId = uuidv4();
  const startupData = {
    id: startupId,
    founderId: uid,
    founderName,
    name: input.name,
    description: input.description,
    industry: input.industry,
    website: input.website ?? "",
    location: input.location ?? "",
    teamSize: input.teamSize,
    logoUrl: null,
    status: "pending", // requires admin approval
    rejectionReason: null,
    createdAt: FieldValue.serverTimestamp(),
    updatedAt: FieldValue.serverTimestamp(),
  };

  await db.collection("startups").doc(startupId).set(startupData);

  // 7. Log action
  functions.logger.info(`Startup created: ${startupId} by ${uid}`);

  return success({ startupId }, "Startup submitted for review");
});