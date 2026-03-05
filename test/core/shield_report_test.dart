import 'package:flutter_neo_shield/flutter_neo_shield.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DetectionEvent', () {
    test('stores type and timestamp', () {
      final ts = DateTime(2024, 1, 1);
      final event = DetectionEvent(type: PIIType.email, timestamp: ts);
      expect(event.type, PIIType.email);
      expect(event.timestamp, ts);
    });

    test('toJson returns correct map', () {
      final ts = DateTime(2024, 1, 1);
      final event = DetectionEvent(type: PIIType.phone, timestamp: ts);
      final json = event.toJson();
      expect(json['type'], 'phone');
      expect(json['timestamp'], ts.toIso8601String());
    });
  });

  group('ShieldReport', () {
    late ShieldReport report;

    setUp(() {
      report = ShieldReport();
    });

    test('totalDetections starts at zero', () {
      expect(report.totalDetections, 0);
    });

    test('recordDetection increments total', () {
      report.recordDetection(PIIType.email);
      expect(report.totalDetections, 1);
    });

    test('recordDetection tracks countsByType', () {
      report.recordDetection(PIIType.email);
      report.recordDetection(PIIType.email);
      report.recordDetection(PIIType.phone);

      expect(report.countsByType[PIIType.email], 2);
      expect(report.countsByType[PIIType.phone], 1);
    });

    test('countsByType returns unmodifiable map', () {
      report.recordDetection(PIIType.email);
      expect(
        () => report.countsByType[PIIType.email] = 999,
        throwsUnsupportedError,
      );
    });

    test('lastDetectionTimestamp is null initially', () {
      expect(report.lastDetectionTimestamp, isNull);
    });

    test('lastDetectionTimestamp updates on record', () {
      report.recordDetection(PIIType.email);
      expect(report.lastDetectionTimestamp, isNotNull);
    });

    test('recentEvents returns recorded events', () {
      report.recordDetection(PIIType.email);
      report.recordDetection(PIIType.phone);
      expect(report.recentEvents, hasLength(2));
      expect(report.recentEvents.first.type, PIIType.email);
      expect(report.recentEvents.last.type, PIIType.phone);
    });

    test('recentEvents caps at maxRecentEvents', () {
      for (var i = 0; i < ShieldReport.maxRecentEvents + 20; i++) {
        report.recordDetection(PIIType.email);
      }
      expect(report.recentEvents, hasLength(ShieldReport.maxRecentEvents));
    });

    test('recentEvents returns unmodifiable list', () {
      report.recordDetection(PIIType.email);
      expect(
        () => report.recentEvents.add(
          DetectionEvent(type: PIIType.phone, timestamp: DateTime.now()),
        ),
        throwsUnsupportedError,
      );
    });

    test('getStats returns correct map', () {
      report.recordDetection(PIIType.email);
      final stats = report.getStats();
      expect(stats['totalDetections'], 1);
      expect(stats['countsByType'], isA<Map>());
      expect(stats['lastDetectionTimestamp'], isNotNull);
      expect(stats['recentEventsCount'], 1);
    });

    test('toJson returns correct map', () {
      report.recordDetection(PIIType.ssn);
      final json = report.toJson();
      expect(json['totalDetections'], 1);
      expect(json['recentEvents'], isA<List>());
      expect((json['recentEvents'] as List).first['type'], 'ssn');
    });

    test('reset clears all data', () {
      report.recordDetection(PIIType.email);
      report.recordDetection(PIIType.phone);
      report.reset();

      expect(report.totalDetections, 0);
      expect(report.countsByType, isEmpty);
      expect(report.lastDetectionTimestamp, isNull);
      expect(report.recentEvents, isEmpty);
    });
  });
}
