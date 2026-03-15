import * as functions from "firebase-functions";
import * as admin from "firebase-admin";

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  message?: string;
  meta?: Record<string, unknown>;
}

export function success<T>(
  data: T,
  message = "OK",
  meta?: Record<string, unknown>
): ApiResponse<T> {
  return { success: true, data, message, meta };
}

export function unauthorized(message = "Unauthorized"): never {
  throw new functions.https.HttpsError("unauthenticated", message);
}

export function forbidden(message = "Forbidden"): never {
  throw new functions.https.HttpsError("permission-denied", message);
}

export function badRequest(message: string): never {
  throw new functions.https.HttpsError("invalid-argument", message);
}

export function notFound(message: string): never {
  throw new functions.https.HttpsError("not-found", message);
}

export function requireAuth(
  context: functions.https.CallableContext
): string {
  if (!context.auth) unauthorized();
  return context.auth!.uid;
}

export function requireRole(
  context: functions.https.CallableContext,
  role: string
): string {
  const uid = requireAuth(context);
  const userRole = context.auth!.token.role as string | undefined;
  if (userRole !== role) forbidden(`Requires ${role} role`);
  return uid;
}

export function requireAnyRole(
  context: functions.https.CallableContext,
  roles: string[]
): string {
  const uid = requireAuth(context);
  const userRole = context.auth!.token.role as string | undefined;
  if (!userRole || !roles.includes(userRole)) {
    forbidden(`Requires one of: ${roles.join(", ")}`);
  }
  return uid;
}

export const db = admin.firestore();
export const auth = admin.auth();
export const FieldValue = admin.firestore.FieldValue;
export const Timestamp = admin.firestore.Timestamp;