/// Dio interceptor for HTTP log sanitization.
///
/// This file requires the `dio` package. Add it to your pubspec.yaml:
///
/// ```yaml
/// dependencies:
///   dio: ^5.0.0
/// ```
///
/// Import this file separately:
/// ```dart
/// import 'package:flutter_neo_shield/dio_shield.dart';
/// ```
library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../core/pii_detector.dart';
import 'json_sanitizer.dart';
import 'safe_log.dart';

/// A Dio [Interceptor] that sanitizes PII from HTTP traffic logs.
///
/// Sanitizes request URLs, headers, and bodies before logging.
/// Requires the `dio` package in your pubspec.yaml.
///
/// ```dart
/// final dio = Dio();
/// dio.interceptors.add(DioShieldInterceptor());
/// ```
class DioShieldInterceptor extends Interceptor {
  /// Creates a [DioShieldInterceptor] with optional configuration.
  ///
  /// ```dart
  /// DioShieldInterceptor(
  ///   sanitizeRequestBody: true,
  ///   sanitizeResponseBody: true,
  ///   logFunction: (msg) => myLogger.info(msg),
  /// );
  /// ```
  DioShieldInterceptor({
    this.logFunction,
    this.sanitizeRequestBody = true,
    this.sanitizeResponseBody = true,
    List<String>? sensitiveHeaders,
  }) : sensitiveHeaders = sensitiveHeaders ??
            const [
              'authorization',
              'proxy-authorization',
              'www-authenticate',
              'cookie',
              'set-cookie',
              'x-api-key',
              'x-auth-token',
              'x-access-token',
              'x-refresh-token',
              'x-api-secret',
              'x-csrf-token',
            ] {
    _sensitiveHeadersLower =
        this.sensitiveHeaders.map((h) => h.toLowerCase()).toSet();
  }

  /// Cached lowercase set of sensitive headers.
  late final Set<String> _sensitiveHeadersLower;

  /// Optional custom log function. Defaults to [shieldLog].
  final void Function(String message)? logFunction;

  /// Whether to sanitize request bodies.
  final bool sanitizeRequestBody;

  /// Whether to sanitize response bodies.
  final bool sanitizeResponseBody;

  /// List of header names to sanitize (case-insensitive).
  final List<String> sensitiveHeaders;

  void _log(String message) {
    if (logFunction != null) {
      logFunction!(message);
    } else {
      shieldLog(message);
    }
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    try {
      final detector = PIIDetector();
      final sanitizedUrl = detector.sanitize(options.uri.toString());

      _log('┌── DIO Request ──');
      _log('│ ${options.method} $sanitizedUrl');

      for (final entry in options.headers.entries) {
        if (_sensitiveHeadersLower.contains(entry.key.toLowerCase())) {
          _log('│ ${entry.key}: [REDACTED]');
        } else {
          _log('│ ${entry.key}: ${detector.sanitize(entry.value.toString())}');
        }
      }

      if (sanitizeRequestBody && options.data != null) {
        if (options.data is Map<String, dynamic>) {
          final sanitized = JsonSanitizer.sanitize(
            options.data as Map<String, dynamic>,
          );
          _log('│ Body: ${const JsonEncoder().convert(sanitized)}');
        } else if (options.data is List<dynamic>) {
          final sanitized = JsonSanitizer.sanitizeList(
            options.data as List<dynamic>,
          );
          _log('│ Body: ${const JsonEncoder().convert(sanitized)}');
        } else {
          _log('│ Body: ${detector.sanitize(options.data.toString())}');
        }
      }

      _log('└──────────────────');
    } catch (_) {
      // Log sanitization failed — continue without logging.
    }
    handler.next(options);
  }

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    try {
      final detector = PIIDetector();

      _log('┌── DIO Response ──');
      _log(
          '│ ${response.statusCode} ${detector.sanitize(response.requestOptions.uri.toString())}');

      if (sanitizeResponseBody && response.data != null) {
        if (response.data is Map<String, dynamic>) {
          final sanitized = JsonSanitizer.sanitize(
            response.data as Map<String, dynamic>,
          );
          _log('│ Body: ${const JsonEncoder().convert(sanitized)}');
        } else if (response.data is List<dynamic>) {
          final sanitized = JsonSanitizer.sanitizeList(
            response.data as List<dynamic>,
          );
          _log('│ Body: ${const JsonEncoder().convert(sanitized)}');
        } else {
          _log('│ Body: ${detector.sanitize(response.data.toString())}');
        }
      }

      _log('└──────────────────');
    } catch (_) {
      // Log sanitization failed — continue without logging.
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    try {
      final detector = PIIDetector();

      _log('┌── DIO Error ──');
      _log('│ ${err.type.name}: ${detector.sanitize(err.message ?? '')}');

      if (err.response?.data != null) {
        if (err.response!.data is Map<String, dynamic>) {
          final sanitized = JsonSanitizer.sanitize(
            err.response!.data as Map<String, dynamic>,
          );
          _log('│ Body: ${const JsonEncoder().convert(sanitized)}');
        } else if (err.response!.data is List<dynamic>) {
          final sanitized = JsonSanitizer.sanitizeList(
            err.response!.data as List<dynamic>,
          );
          _log('│ Body: ${const JsonEncoder().convert(sanitized)}');
        } else {
          _log('│ Body: ${detector.sanitize(err.response!.data.toString())}');
        }
      }

      _log('└──────────────────');
    } catch (_) {
      // Log sanitization failed — continue without logging.
    }
    handler.next(err);
  }
}
