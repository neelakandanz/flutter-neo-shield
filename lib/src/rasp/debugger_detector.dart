import '../platform/rasp_channel.dart';
import 'security_result.dart';

/// Detects if a debugger is currently attached to the application process.
class DebuggerDetector {
  /// Executes the detection check on the native platform.
  static Future<SecurityResult> check() async {
    final isDetected = await RaspChannel.invokeDetection('checkDebugger');
    return SecurityResult(
      isDetected: isDetected,
      message:
          isDetected ? 'Debugger attached or PT_TRACE_ME flag found' : null,
    );
  }
}
