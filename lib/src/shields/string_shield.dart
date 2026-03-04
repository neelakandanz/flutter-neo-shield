/// String Shield module — compile-time string obfuscation for Flutter.
///
/// Protects sensitive string constants from reverse engineering by
/// replacing them with encrypted byte arrays at build time.
/// Strings are transparently decrypted at runtime.
///
/// ```dart
/// import 'package:flutter_neo_shield/string_shield.dart';
///
/// part 'secrets.g.dart';
///
/// @ObfuscateClass()
/// abstract class AppSecrets {
///   @Obfuscate()
///   static const String apiUrl = 'https://api.myapp.com/v2';
/// }
///
/// // Usage:
/// final url = $AppSecrets.apiUrl;
/// ```
library string_shield;

// Core (shared PII engine)
export '../core/pii_detector.dart';
export '../core/pii_pattern.dart';
export '../core/pii_type.dart';
export '../core/shield_config.dart';
export '../core/shield_report.dart';

// String Shield
export '../string_shield/annotations.dart';
export '../string_shield/deobfuscator.dart';
export '../string_shield/obfuscation_strategy.dart';
export '../string_shield/string_shield.dart';
export '../string_shield/string_shield_config.dart';
