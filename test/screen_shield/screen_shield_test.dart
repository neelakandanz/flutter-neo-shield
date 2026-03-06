import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_neo_shield/flutter_neo_shield.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ScreenShield shield;
  final List<MethodCall> methodCalls = [];
  bool protectionEnabled = false;

  setUp(() {
    shield = ScreenShield();
    shield.reset();
    methodCalls.clear();
    protectionEnabled = false;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('com.neelakandan.flutter_neo_shield/screen'),
      (MethodCall call) async {
        methodCalls.add(call);
        switch (call.method) {
          case 'enableScreenProtection':
            protectionEnabled = true;
            return true;
          case 'disableScreenProtection':
            protectionEnabled = false;
            return true;
          case 'isScreenProtectionActive':
            return protectionEnabled;
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

  group('ScreenShield', () {
    test('is a singleton', () {
      expect(identical(ScreenShield(), ScreenShield()), isTrue);
    });

    test('is not initialized by default', () {
      expect(shield.isInitialized, isFalse);
    });

    test('init sets initialized flag', () async {
      await shield.init(const ScreenShieldConfig(enableOnInit: false));
      expect(shield.isInitialized, isTrue);
    });

    test('enableProtection calls native method', () async {
      final result = await shield.enableProtection();
      expect(result, isTrue);
      expect(shield.isProtectionActive, isTrue);
      expect(methodCalls.last.method, 'enableScreenProtection');
    });

    test('disableProtection calls native method', () async {
      await shield.enableProtection();
      final result = await shield.disableProtection();
      expect(result, isTrue);
      expect(shield.isProtectionActive, isFalse);
      expect(methodCalls.last.method, 'disableScreenProtection');
    });

    test('isProtectionActiveNative queries native state', () async {
      await shield.enableProtection();
      final result = await shield.isProtectionActiveNative;
      expect(result, isTrue);
      expect(methodCalls.last.method, 'isScreenProtectionActive');
    });

    test('enableAppSwitcherGuard calls native method', () async {
      final result = await shield.enableAppSwitcherGuard();
      expect(result, isTrue);
      expect(shield.isAppSwitcherGuardActive, isTrue);
      expect(methodCalls.last.method, 'enableAppSwitcherGuard');
    });

    test('disableAppSwitcherGuard calls native method', () async {
      await shield.enableAppSwitcherGuard();
      final result = await shield.disableAppSwitcherGuard();
      expect(result, isTrue);
      expect(shield.isAppSwitcherGuardActive, isFalse);
    });

    test('isScreenBeingRecorded queries native', () async {
      final result = await shield.isScreenBeingRecorded;
      expect(result, isFalse);
      expect(methodCalls.last.method, 'isScreenBeingRecorded');
    });

    test('init with enableOnInit enables protection automatically', () async {
      await shield.init(const ScreenShieldConfig(
        enableOnInit: true,
        blockScreenshots: true,
        blockRecording: true,
        guardAppSwitcher: true,
      ));

      expect(shield.isProtectionActive, isTrue);
      expect(shield.isAppSwitcherGuardActive, isTrue);
      final methods = methodCalls.map((c) => c.method).toList();
      expect(methods, contains('enableScreenProtection'));
      expect(methods, contains('enableAppSwitcherGuard'));
    });

    test('init with enableOnInit false does not enable protection', () async {
      await shield.init(const ScreenShieldConfig(enableOnInit: false));

      expect(shield.isProtectionActive, isFalse);
      expect(shield.isAppSwitcherGuardActive, isFalse);
      expect(methodCalls, isEmpty);
    });

    test('dispose disables active protection', () async {
      await shield.enableProtection();
      await shield.enableAppSwitcherGuard();
      await shield.dispose();

      expect(shield.isProtectionActive, isFalse);
      expect(shield.isAppSwitcherGuardActive, isFalse);
    });

    test('reset clears all state', () async {
      await shield.init(const ScreenShieldConfig(enableOnInit: false));
      await shield.enableProtection();
      shield.reset();

      expect(shield.isInitialized, isFalse);
      expect(shield.isProtectionActive, isFalse);
      expect(shield.isAppSwitcherGuardActive, isFalse);
    });
  });

  group('ScreenShieldConfig', () {
    test('has sensible defaults', () {
      const config = ScreenShieldConfig();
      expect(config.enableOnInit, isTrue);
      expect(config.blockScreenshots, isTrue);
      expect(config.blockRecording, isTrue);
      expect(config.guardAppSwitcher, isTrue);
      expect(config.detectScreenshots, isTrue);
      expect(config.detectRecording, isTrue);
      expect(config.appSwitcherBlurSigma, 30.0);
    });

    test('copyWith preserves unchanged values', () {
      const config = ScreenShieldConfig();
      final copy = config.copyWith(blockScreenshots: false);
      expect(copy.blockScreenshots, isFalse);
      expect(copy.enableOnInit, isTrue);
      expect(copy.blockRecording, isTrue);
    });
  });
}
