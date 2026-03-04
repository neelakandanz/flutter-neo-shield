/// Log Shield module — PII-sanitized logging for Flutter.
///
/// Provides structured, PII-sanitized logging that automatically
/// redacts sensitive data.
///
/// ```dart
/// import 'package:flutter_neo_shield/log_shield.dart';
///
/// shieldLog('User email: john@test.com');
/// // Output: [INFO] User email: [EMAIL HIDDEN]
/// ```
library log_shield;

// Core (shared PII engine)
export '../core/pii_detector.dart';
export '../core/pii_pattern.dart';
export '../core/pii_type.dart';
export '../core/shield_config.dart';
export '../core/shield_report.dart';

// Log Shield
export '../log_shield/json_sanitizer.dart';
export '../log_shield/log_shield.dart';
export '../log_shield/log_shield_config.dart';
export '../log_shield/safe_log.dart';
