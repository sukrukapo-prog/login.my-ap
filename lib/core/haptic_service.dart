import 'package:flutter/services.dart';

/// Central haptic feedback service.
/// Use this instead of calling HapticFeedback directly in screens.
///
/// Usage:
///   HapticService.light();   ← for small taps, toggles
///   HapticService.medium();  ← for buttons, selections
///   HapticService.heavy();   ← for confirmations, completions
///   HapticService.success(); ← for success actions
///   HapticService.error();   ← for errors or warnings
class HapticService {
  HapticService._();

  /// Light tap — small UI interactions, toggles, chips
  static Future<void> light() => HapticFeedback.lightImpact();

  /// Medium tap — buttons, card taps, tab switches
  static Future<void> medium() => HapticFeedback.mediumImpact();

  /// Heavy tap — confirmations, session complete, major actions
  static Future<void> heavy() => HapticFeedback.heavyImpact();

  /// Selection click — list items, radio buttons, dropdowns
  static Future<void> selection() => HapticFeedback.selectionClick();

  /// Vibrate — errors, warnings, invalid input
  static Future<void> error() => HapticFeedback.vibrate();
}
