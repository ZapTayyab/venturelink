import * as admin from "firebase-admin";

admin.initializeApp();

// Export all functions
export { createStartup } from "./startups/createStartup";
export { updateStartup } from "./startups/updateStartup";
export { moderateStartup } from "./startups/moderateStartup";
export { createFundingRound } from "./rounds/createFundingRound";
export { makeInvestment } from "./investments/makeInvestment";
export { getPlatformMetrics } from "./admin/getPlatformMetrics";
export { onUserCreated } from "./auth/onUserCreated";
export { healthCheck } from "./utils/healthCheck";