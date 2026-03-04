import '../platform/rasp_channel.dart';
import 'security_result.dart';

/// Detects if the device is rooted (Android) or jailbroken (iOS).
class RootDetector {
  /// Executes the detection check on the native platform.
  static Future<SecurityResult> check() async {
    final isDetected = await RaspChannel.invokeDetection('checkRoot');
    return SecurityResult(
      isDetected: isDetected,
      message: isDetected ? 'Device is rooted or jailbroken' : null,
    );
  }
}
