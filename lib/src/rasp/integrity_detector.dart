import '../platform/rasp_channel.dart';
import 'security_result.dart';

/// Detects issues with app binary integrity and suspicious installation sources.
class IntegrityDetector {
  /// Executes the detection check on the native platform.
  static Future<SecurityResult> check() async {
    final isDetected = await RaspChannel.invokeDetection('checkIntegrity');
    return SecurityResult(
      isDetected: isDetected,
      message: isDetected
          ? 'Application integrity compromised (Tampering detected)'
          : null,
    );
  }
}
