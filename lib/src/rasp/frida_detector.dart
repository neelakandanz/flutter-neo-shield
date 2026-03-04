import '../platform/rasp_channel.dart';
import 'security_result.dart';

/// Detects the presence of Frida instrumentation frameworks.
class FridaDetector {
  /// Executes the detection check on the native platform.
  static Future<SecurityResult> check() async {
    final isDetected = await RaspChannel.invokeDetection('checkFrida');
    return SecurityResult(
      isDetected: isDetected,
      message: isDetected ? 'Frida instrumentation detected' : null,
    );
  }
}
