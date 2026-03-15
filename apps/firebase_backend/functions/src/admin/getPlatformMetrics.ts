import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
import { requireAuth, db, forbidden, success } from "../utils/helpers";

export const getPlatformMetrics = functions.https.onCall(
  async (data, context) => {
    const uid = requireAuth(context);

    const claimRole = context.auth!.token.role as string | undefined;
    let isAdmin = claimRole === "admin";

    if (!isAdmin) {
      const userDoc = await db.collection("users").doc(uid).get();
      isAdmin = userDoc.data()?.role === "admin";
    }

    if (!isAdmin) forbidden("Admin access required");

    const [usersSnap, startupsSnap, roundsSnap, investmentsSnap] =
      await Promise.all([
        db.collection("users").count().get(),
        db.collection("startups").count().get(),
        db.collection("fundingRounds").count().get(),
        db.collection("investments").get(),
      ]);

    const totalUsers = usersSnap.data().count;
    const totalStartups = startupsSnap.data().count;
    const totalRounds = roundsSnap.data().count;

    let totalRaised = 0;
    let totalInvestments = 0;

    investmentsSnap.forEach((doc: admin.firestore.QueryDocumentSnapshot) => {
      const d = doc.data();
      if (d.status === "confirmed") {
        totalRaised += (d.amount as number) ?? 0;
        totalInvestments++;
      }
    });

    const pendingSnap = await db
      .collection("startups")
      .where("status", "==", "pending")
      .count()
      .get();

    return success(
      {
        totalUsers,
        totalStartups,
        totalRounds,
        totalInvestments,
        totalRaised,
        pendingStartups: pendingSnap.data().count,
        generatedAt: new Date().toISOString(),
      },
      "Metrics fetched"
    );
  }
);