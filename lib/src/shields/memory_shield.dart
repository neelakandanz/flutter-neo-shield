/// Memory Shield module — secure memory wipe for Flutter.
///
/// Provides secure containers for sensitive strings and byte arrays
/// that overwrite their content with zeros on dispose.
///
/// ```dart
/// import 'package:flutter_neo_shield/memory_shield.dart';
///
/// final secret = SecureString('my-api-key');
/// print(secret.value); // 'my-api-key'
/// secret.dispose();
/// ```
library memory_shield;

// Core (shared PII engine)
export '../core/pii_detector.dart';
export '../core/pii_pattern.dart';
export '../core/pii_type.dart';
export '../core/shield_config.dart';
export '../core/shield_report.dart';

// Memory Shield
export '../memory_shield/memory_shield.dart';
export '../memory_shield/memory_shield_config.dart';
export '../memory_shield/secure_bytes.dart';
export '../memory_shield/secure_string.dart';
export '../memory_shield/secure_value.dart';
