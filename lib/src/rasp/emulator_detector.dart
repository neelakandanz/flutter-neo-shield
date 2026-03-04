import '../platform/rasp_channel.dart';
import 'security_result.dart';

/// Detects if the application is running on an emulator or simulator.
class EmulatorDetector {
  /// Executes the detection check on the native platform.
  static Future<SecurityResult> check() async {
    final isDetected = await RaspChannel.invokeDetection('checkEmulator');
    return SecurityResult(
      isDetected: isDetected,
      message: isDetected ? 'App is running on an emulator/simulator' : null,
    );
  }
}
