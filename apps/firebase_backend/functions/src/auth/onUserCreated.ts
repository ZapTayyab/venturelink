import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

const db = admin.firestore();
const FieldValue = admin.firestore.FieldValue;

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  const { uid, email, displayName } = user;

  functions.logger.info(`New user created: ${uid} (${email})`);

  try {
    await db.collection("users").doc(uid).set({
      uid,
      email: email ?? "",
      displayName: displayName ?? email?.split("@")[0] ?? "User",
      role: "investor",
      isVerified: false,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp(),
    });
    functions.logger.info(`User document created for ${uid}`);
  } catch (err) {
    functions.logger.error(`Failed to create user document for ${uid}`, err);
  }
});