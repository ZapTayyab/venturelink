import * as functions from "firebase-functions";
import { db } from "./helpers";

export const healthCheck = functions.https.onRequest(async (req, res) => {
  try {
    // Quick Firestore ping
    await db.collection("_health").doc("ping").set({
      timestamp: new Date().toISOString(),
    });
    res.status(200).json({
      status: "ok",
      timestamp: new Date().toISOString(),
      version: "1.0.0",
      project: process.env.GCLOUD_PROJECT,
    });
  } catch (e) {
    res.status(500).json({ status: "error", message: String(e) });
  }
});