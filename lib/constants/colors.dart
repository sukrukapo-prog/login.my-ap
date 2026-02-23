import 'package:flutter/material.dart';

class AppColors {
  // Core theme colors
  static const Color background = Color(0xFF0F1624);      // dark navy background
  static const Color primary = Color(0xFF3B82F6);         // main blue for buttons & accents
  static const Color primaryLight = Color(0xFF60A5FA);    // lighter blue for text/links
  static const Color primaryDark = Color(0xFF2563EB);     // darker hover/pressed state

  // Text & icons
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFB3B3B3);   // white70 ≈ 70% opacity
  static const Color textHint = Color(0xFF94A3B8);        // muted hints
  static const Color textDisabled = Color(0xFF64748B);

  // Surface / cards / inputs
  static const Color surface = Color(0xFF1E293B);         // slightly lighter dark for cards
  static const Color surfaceVariant = Color(0xFF334155);
  static const Color inputFill = Color(0xFF1E293B);       // input background
  static const Color divider = Color(0xFF334155);

  // Status / feedback
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Overlay / shadow
  static const Color shadow = Color(0xFF000000);
}