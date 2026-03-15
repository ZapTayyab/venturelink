import { z } from "zod";
import { badRequest } from "./helpers";

export function validate<T>(schema: z.ZodSchema<T>, data: unknown): T {
  const result = schema.safeParse(data);
  if (!result.success) {
    const messages = result.error.errors
      .map((e) => `${e.path.join(".")}: ${e.message}`)
      .join(", ");
    badRequest(`Validation failed: ${messages}`);
  }
  return result.data;
}

// ── Shared schemas ───────────────────────────────────────────

export const createStartupSchema = z.object({
  name: z.string().min(2).max(100),
  description: z.string().min(20).max(2000),
  industry: z.string().min(2).max(50),
  website: z.string().url().optional().or(z.literal("")),
  location: z.string().max(100).optional(),
  teamSize: z.number().int().min(1).max(10000),
});

export const updateStartupSchema = z.object({
  startupId: z.string().min(1),
  name: z.string().min(2).max(100).optional(),
  description: z.string().min(20).max(2000).optional(),
  industry: z.string().min(2).max(50).optional(),
  website: z.string().url().optional().or(z.literal("")),
  location: z.string().max(100).optional(),
  teamSize: z.number().int().min(1).max(10000).optional(),
});

export const moderateStartupSchema = z.object({
  startupId: z.string().min(1),
  action: z.enum(["approve", "reject", "suspend"]),
  note: z.string().max(500).optional(),
});

export const createRoundSchema = z.object({
  startupId: z.string().min(1),
  title: z.string().min(2).max(100),
  targetAmount: z.number().min(1000),
  minInvestment: z.number().min(1),
  deadline: z.string().datetime().or(z.string().min(1)),
});

export const makeInvestmentSchema = z.object({
  roundId: z.string().min(1),
  startupId: z.string().min(1),
  amount: z.number().min(1),
  investmentId: z.string().optional(),
});

export const getPlatformMetricsSchema = z.object({}).optional();