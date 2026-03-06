import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_neo_shield/src/platform/screen_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> methodCalls = [];

  setUp(() {
    methodCalls.clear();
    ScreenChannel.resetForTesting();

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.neelakandan.flutter_neo_shield/screen'),
      (MethodCall call) async {
        methodCalls.add(call);
        switch (call.method) {
          case 'enableScreenProtection':
            return true;
          case 'disableScreenProtection':
            return true;
          case 'isScreenProtectionActive':
            return true;
          case 'enableAppSwitcherGuard':
            return true;
          case 'disableAppSwitcherGuard':
            return true;
          case 'isScreenBeingRecorded':
            return false;
          default:
            return null;
        }
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.neelakandan.flutter_neo_shield/screen'),
      null,
    );
  });

  group('ScreenChannel', () {
    test('enableProtection sends correct method call', () async {
      final result = await ScreenChannel.enableProtection();
      expect(result, isTrue);
      expect(methodCalls.single.method, 'enableScreenProtection');
    });

    test('disableProtection sends correct method call', () async {
      final result = await ScreenChannel.disableProtection();
      expect(result, isTrue);
      expect(methodCalls.single.method, 'disableScreenProtection');
    });

    test('isProtectionActive sends correct method call', () async {
      final result = await ScreenChannel.isProtectionActive();
      expect(result, isTrue);
      expect(methodCalls.single.method, 'isScreenProtectionActive');
    });

    test('enableAppSwitcherGuard sends correct method call', () async {
      final result = await ScreenChannel.enableAppSwitcherGuard();
      expect(result, isTrue);
      expect(methodCalls.single.method, 'enableAppSwitcherGuard');
    });

    test('disableAppSwitcherGuard sends correct method call', () async {
      final result = await ScreenChannel.disableAppSwitcherGuard();
      expect(result, isTrue);
      expect(methodCalls.single.method, 'disableAppSwitcherGuard');
    });

    test('isScreenBeingRecorded sends correct method call', () async {
      final result = await ScreenChannel.isScreenBeingRecorded();
      expect(result, isFalse);
      expect(methodCalls.single.method, 'isScreenBeingRecorded');
    });

    test('returns false when plugin not registered', () async {
      // Remove mock handler to simulate missing plugin
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('com.neelakandan.flutter_neo_shield/screen'),
        null,
      );

      final result = await ScreenChannel.enableProtection();
      expect(result, isFalse);
    });
  });
}
