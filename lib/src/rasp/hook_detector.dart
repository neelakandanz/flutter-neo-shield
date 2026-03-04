import '../platform/rasp_channel.dart';
import 'security_result.dart';

/// Detects the presence of hooking frameworks (e.g., Xposed, Substrate, Cycript).
class HookDetector {
  /// Executes the detection check on the native platform.
  static Future<SecurityResult> check() async {
    final isDetected = await RaspChannel.invokeDetection('checkHooks');
    return SecurityResult(
      isDetected: isDetected,
      message: isDetected
          ? 'Hooking framework (e.g. Xposed/Substrate) detected'
          : null,
    );
  }
}
