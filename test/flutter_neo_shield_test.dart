import 'package:flutter_neo_shield/flutter_neo_shield.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlutterNeoShield.reset();
  });

  group('FlutterNeoShield', () {
    test('isInitialized is false by default', () {
      expect(FlutterNeoShield.isInitialized, isFalse);
    });

    test('init sets isInitialized to true', () {
      FlutterNeoShield.init();
      expect(FlutterNeoShield.isInitialized, isTrue);
    });

    test('reset sets isInitialized to false', () {
      FlutterNeoShield.init();
      FlutterNeoShield.reset();
      expect(FlutterNeoShield.isInitialized, isFalse);
    });

    test('double init does not throw', () {
      FlutterNeoShield.init();
      FlutterNeoShield.init();
      expect(FlutterNeoShield.isInitialized, isTrue);
    });

    test('detector returns PIIDetector singleton', () {
      FlutterNeoShield.init();
      final d1 = FlutterNeoShield.detector;
      final d2 = FlutterNeoShield.detector;
      expect(identical(d1, d2), isTrue);
    });

    test('log returns LogShield singleton', () {
      FlutterNeoShield.init();
      expect(FlutterNeoShield.log, isA<LogShield>());
    });

    test('clipboard returns ClipboardShield singleton', () {
      FlutterNeoShield.init();
      expect(FlutterNeoShield.clipboard, isA<ClipboardShield>());
    });

    test('memory returns MemoryShield singleton', () {
      FlutterNeoShield.init();
      expect(FlutterNeoShield.memory, isA<MemoryShield>());
    });

    test('stringShield returns StringShield singleton', () {
      FlutterNeoShield.init();
      expect(FlutterNeoShield.stringShield, isA<StringShield>());
    });

    test('report returns null when reporting disabled', () {
      FlutterNeoShield.init();
      expect(FlutterNeoShield.report, isNull);
    });

    test('report returns ShieldReport when reporting enabled', () {
      FlutterNeoShield.init(
        config: const ShieldConfig(enableReporting: true),
      );
      expect(FlutterNeoShield.report, isNotNull);
    });

    test('init with config configures PIIDetector', () {
      FlutterNeoShield.init(
        config: const ShieldConfig(
          enabledTypes: {PIIType.email},
        ),
      );

      final detector = FlutterNeoShield.detector;
      expect(detector.config.enabledTypes, {PIIType.email});
    });
  });
}
