import 'package:flutter/services.dart';
import 'dart:developer' as developer;

/// Handles communication between Flutter and Native layer for RASP checks
class RaspChannel {
  static const MethodChannel _channel =
      MethodChannel('com.neelakandan.flutter_neo_shield/rasp');

  /// Invoke a native detection method
  static Future<bool> invokeDetection(String method,
      [Map<String, dynamic>? arguments]) async {
    try {
      final result = await _channel.invokeMethod<bool>(method, arguments);
      return result ?? false;
    } on PlatformException catch (e) {
      developer.log('Failed to execute $method: ${e.message}',
          name: 'RaspChannel');
      return false;
    }
  }
}
