import 'package:flutter_neo_shield/flutter_neo_shield.dart';
import 'package:flutter_neo_shield/src/core/pii_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PIIType', () {
    test('has all expected values', () {
      expect(PIIType.values, hasLength(16));
    });

    test('displayName returns correct strings', () {
      expect(PIIType.email.displayName, 'Email');
      expect(PIIType.phone.displayName, 'Phone');
      expect(PIIType.ssn.displayName, 'SSN');
      expect(PIIType.creditCard.displayName, 'Credit Card');
      expect(PIIType.dateOfBirth.displayName, 'Date of Birth');
      expect(PIIType.ipAddress.displayName, 'IP Address');
      expect(PIIType.jwtToken.displayName, 'JWT Token');
      expect(PIIType.bearerToken.displayName, 'Bearer Token');
      expect(PIIType.passwordField.displayName, 'Password Field');
      expect(PIIType.apiKey.displayName, 'API Key');
      expect(PIIType.iban.displayName, 'IBAN');
      expect(PIIType.ukNin.displayName, 'UK NI Number');
      expect(PIIType.canadianSin.displayName, 'Canadian SIN');
      expect(PIIType.passport.displayName, 'Passport');
      expect(PIIType.name.displayName, 'Name');
      expect(PIIType.custom.displayName, 'Custom');
    });
  });

  group('PIIMatch', () {
    test('equality works for identical matches', () {
      const a = PIIMatch(
        type: PIIType.email,
        original: 'john@test.com',
        start: 0,
        end: 13,
        replacement: '[EMAIL HIDDEN]',
      );
      const b = PIIMatch(
        type: PIIType.email,
        original: 'john@test.com',
        start: 0,
        end: 13,
        replacement: '[EMAIL HIDDEN]',
      );
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('inequality when type differs', () {
      const a = PIIMatch(
        type: PIIType.email,
        original: 'test',
        start: 0,
        end: 4,
        replacement: '[HIDDEN]',
      );
      const b = PIIMatch(
        type: PIIType.phone,
        original: 'test',
        start: 0,
        end: 4,
        replacement: '[HIDDEN]',
      );
      expect(a, isNot(equals(b)));
    });

    test('inequality when position differs', () {
      const a = PIIMatch(
        type: PIIType.email,
        original: 'test',
        start: 0,
        end: 4,
        replacement: '[HIDDEN]',
      );
      const b = PIIMatch(
        type: PIIType.email,
        original: 'test',
        start: 5,
        end: 9,
        replacement: '[HIDDEN]',
      );
      expect(a, isNot(equals(b)));
    });

    test('toString does not include original text', () {
      const match = PIIMatch(
        type: PIIType.email,
        original: 'john@test.com',
        start: 0,
        end: 13,
        replacement: '[EMAIL HIDDEN]',
      );
      final str = match.toString();
      expect(str, isNot(contains('john@test.com')));
      expect(str, contains('PIIMatch'));
      expect(str, contains('email'));
      expect(str, contains('[EMAIL HIDDEN]'));
    });
  });
}
