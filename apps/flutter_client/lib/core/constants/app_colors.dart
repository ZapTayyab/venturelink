import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand Core ──────────────────────────────────────────────
  // Deep navy + electric blue + gold — classic fintech/VC palette
  static const Color primary        = Color(0xFF1A73E8); // Electric blue
  static const Color primaryDark    = Color(0xFF0D47A1); // Deep navy blue
  static const Color primaryLight   = Color(0xFF4FC3F7); // Sky blue
  static const Color secondary      = Color(0xFF00C896); // Emerald green
  static const Color secondaryDark  = Color(0xFF00956E);
  static const Color accent         = Color(0xFFFFB300); // Gold
  static const Color accentGold     = Color(0xFFFFD54F);
  static const Color accentGreen    = Color(0xFF00E5A0);

  // ── Background System ────────────────────────────────────────
  static const Color background     = Color(0xFFF0F4FF);
  static const Color surface        = Color(0xFFFFFFFF);
  static const Color surfaceDark    = Color(0xFF0A0F2C);

  // ── Gradients ────────────────────────────────────────────────

  // Splash: deep space navy — like a Bloomberg terminal
  static const LinearGradient splashGradient = LinearGradient(
    colors: [
      Color(0xFF020818),
      Color(0xFF0A1628),
      Color(0xFF0D2137),
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Primary CTA — electric blue to cyan
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card header — navy to royal blue
  static const LinearGradient navyGradient = LinearGradient(
    colors: [Color(0xFF0A1628), Color(0xFF1A3A5C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Success / invest — emerald
  static const LinearGradient greenGradient = LinearGradient(
    colors: [Color(0xFF00C896), Color(0xFF00E5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Premium / gold
  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFF8C00), Color(0xFFFFD700)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Blockchain — purple to blue
  static const LinearGradient blockchainGradient = LinearGradient(
    colors: [Color(0xFF7B2FBE), Color(0xFF1A73E8), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Card gradient — electric blue
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1A73E8), Color(0xFF00B4D8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Semantic ─────────────────────────────────────────────────
  static const Color success    = Color(0xFF00C896);
  static const Color warning    = Color(0xFFFFB300);
  static const Color error      = Color(0xFFEF4444);
  static const Color info       = Color(0xFF1A73E8);

  // ── Neutral ──────────────────────────────────────────────────
  static const Color white      = Color(0xFFFFFFFF);
  static const Color black      = Color(0xFF020818);
  static const Color grey100    = Color(0xFFF0F4FF);
  static const Color grey200    = Color(0xFFE1E8FF);
  static const Color grey300    = Color(0xFFCDD5E0);
  static const Color grey400    = Color(0xFF94A3B8);
  static const Color grey500    = Color(0xFF64748B);
  static const Color grey600    = Color(0xFF475569);
  static const Color grey700    = Color(0xFF334155);
  static const Color grey800    = Color(0xFF1E293B);
  static const Color grey900    = Color(0xFF0F172A);

  // ── Status chips ─────────────────────────────────────────────
  static const Color pendingBg    = Color(0xFFFFF8E1);
  static const Color pendingText  = Color(0xFFFF8C00);
  static const Color approvedBg   = Color(0xFFE8FFF5);
  static const Color approvedText = Color(0xFF00956E);
  static const Color rejectedBg   = Color(0xFFFFEEEE);
  static const Color rejectedText = Color(0xFFEF4444);

  // ── Blockchain specific ───────────────────────────────────────
  static const Color blockchainPurple = Color(0xFF7B2FBE);
  static const Color blockchainBlue   = Color(0xFF1A73E8);
}