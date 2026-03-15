import * as functions from "firebase-functions";
import {
  requireAuth,
  db,
  FieldValue,
  forbidden,
  notFound,
  success,
} from "../utils/helpers";
import { validate, updateStartupSchema } from "../utils/validation";

export const updateStartup = functions.https.onCall(async (data, context) => {
  const uid = requireAuth(context);
  const input = validate(updateStartupSchema, data);

  // Get startup
  const startupRef = db.collection("startups").doc(input.startupId);
  const startupDoc = await startupRef.get();

  if (!startupDoc.exists) notFound("Startup not found");

  const startup = startupDoc.data()!;

  // Only owner or admin can update
  const role = context.auth!.token.role as string | undefined;
  if (startup.founderId !== uid && role !== "admin") {
    forbidden("Not authorized to update this startup");
  }

  // Build update object — only include provided fields
  const updates: Record<string, unknown> = {
    updatedAt: FieldValue.serverTimestamp(),
  };
  if (input.name !== undefined) updates.name = input.name;
  if (input.description !== undefined) updates.description = input.description;
  if (input.industry !== undefined) updates.industry = input.industry;
  if (input.website !== undefined) updates.website = input.website;
  if (input.location !== undefined) updates.location = input.location;
  if (input.teamSize !== undefined) updates.teamSize = input.teamSize;

  await startupRef.update(updates);

  functions.logger.info(`Startup ${input.startupId} updated by ${uid}`);

  return success({ startupId: input.startupId }, "Startup updated");
});