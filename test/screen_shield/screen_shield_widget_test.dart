import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_neo_shield/flutter_neo_shield.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> methodCalls = [];

  setUp(() {
    methodCalls.clear();
    ScreenShield().reset();

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
          case 'enableAppSwitcherGuard':
            return true;
          case 'disableAppSwitcherGuard':
            return true;
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

  group('ScreenShieldScope', () {
    testWidgets('enables protection on mount', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShieldScope(
            child: Text('Protected'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final methods = methodCalls.map((c) => c.method).toList();
      expect(methods, contains('enableScreenProtection'));
      expect(methods, contains('enableAppSwitcherGuard'));
    });

    testWidgets('disables protection on dispose', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (_) => const ScreenShieldScope(
                child: Text('Protected'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      methodCalls.clear();

      // Navigate away to dispose ScreenShieldScope
      await tester.pumpWidget(
        const MaterialApp(
          home: Text('Unprotected'),
        ),
      );
      await tester.pumpAndSettle();

      final methods = methodCalls.map((c) => c.method).toList();
      expect(methods, contains('disableScreenProtection'));
      expect(methods, contains('disableAppSwitcherGuard'));
    });

    testWidgets('does not disable on dispose when disableOnDispose is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShieldScope(
            disableOnDispose: false,
            child: Text('Protected'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      methodCalls.clear();

      await tester.pumpWidget(
        const MaterialApp(
          home: Text('Unprotected'),
        ),
      );
      await tester.pumpAndSettle();

      final methods = methodCalls.map((c) => c.method).toList();
      expect(methods, isNot(contains('disableScreenProtection')));
    });

    testWidgets('respects enableProtection false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShieldScope(
            enableProtection: false,
            guardAppSwitcher: false,
            child: Text('Not protected'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final methods = methodCalls.map((c) => c.method).toList();
      expect(methods, contains('disableScreenProtection'));
      expect(methods, contains('disableAppSwitcherGuard'));
    });

    testWidgets('renders child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ScreenShieldScope(
            child: Text('Hello Screen Shield'),
          ),
        ),
      );

      expect(find.text('Hello Screen Shield'), findsOneWidget);
    });
  });
}
