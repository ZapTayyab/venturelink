import * as functions from "firebase-functions";
import { v4 as uuidv4 } from "uuid";
import {
  db,
  FieldValue,
  notFound,
  success,
  requireAuth,
  forbidden,
} from "../utils/helpers";
import { validate, moderateStartupSchema } from "../utils/validation";

export const moderateStartup = functions.https.onCall(
  async (data, context) => {
    const uid = requireAuth(context);

    // Admin check — check custom claim and Firestore role
    const claimRole = context.auth!.token.role as string | undefined;
    let isAdmin = claimRole === "admin";

    if (!isAdmin) {
      const userDoc = await db.collection("users").doc(uid).get();
      isAdmin = userDoc.data()?.role === "admin";
    }

    if (!isAdmin) forbidden("Admin access required");

    const input = validate(moderateStartupSchema, data);

    // Get startup
    const startupRef = db.collection("startups").doc(input.startupId);
    const startupDoc = await startupRef.get();
    if (!startupDoc.exists) notFound("Startup not found");

    const startup = startupDoc.data()!;
    const previousStatus = startup.status;

    // Map action to status
    const newStatus =
      input.action === "approve"
        ? "approved"
        : input.action === "reject"
        ? "rejected"
        : "suspended";

    // Update startup
    await startupRef.update({
      status: newStatus,
      rejectionReason: input.action === "reject" ? (input.note ?? null) : null,
      updatedAt: FieldValue.serverTimestamp(),
    });

    // Write audit log — immutable
    const logId = uuidv4();
    await db.collection("adminActionLogs").doc(logId).set({
      id: logId,
      adminId: uid,
      targetType: "startup",
      targetId: input.startupId,
      action: input.action,
      previousStatus,
      newStatus,
      note: input.note ?? null,
      createdAt: FieldValue.serverTimestamp(),
    });

    functions.logger.info(
      `Startup ${input.startupId} ${input.action}d by admin ${uid}`
    );

    return success(
      { startupId: input.startupId, newStatus },
      `Startup ${input.action}d successfully`
    );
  }
);