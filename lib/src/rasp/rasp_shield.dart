import 'debugger_detector.dart';
import 'emulator_detector.dart';
import 'frida_detector.dart';
import 'hook_detector.dart';
import 'integrity_detector.dart';
import 'root_detector.dart';
import 'security_result.dart';

/// Runtime App Self Protection (RASP) main interface
class RaspShield {
  RaspShield._();

  /// Checks for active debuggers
  static Future<SecurityResult> checkDebugger() => DebuggerDetector.check();

  /// Checks for device rooted / jailbreak status
  static Future<SecurityResult> checkRoot() => RootDetector.check();

  /// Checks if running inside an emulator
  static Future<SecurityResult> checkEmulator() => EmulatorDetector.check();

  /// Checks for Frida injection
  static Future<SecurityResult> checkFrida() => FridaDetector.check();

  /// Checks for hooking frameworks (Xposed, Substrate, Magisk modules)
  static Future<SecurityResult> checkHooks() => HookDetector.check();

  /// Checks application binary integrity against tampering
  static Future<SecurityResult> checkIntegrity() => IntegrityDetector.check();

  /// Perform a full security scan returning all results.
  static Future<SecurityReport> fullSecurityScan() async {
    return SecurityReport(
      debuggerDetected: (await checkDebugger()).isDetected,
      rootDetected: (await checkRoot()).isDetected,
      emulatorDetected: (await checkEmulator()).isDetected,
      fridaDetected: (await checkFrida()).isDetected,
      hookDetected: (await checkHooks()).isDetected,
      integrityTampered: (await checkIntegrity()).isDetected,
    );
  }
}
