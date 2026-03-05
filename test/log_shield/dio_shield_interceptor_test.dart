import 'package:dio/dio.dart';
import 'package:flutter_neo_shield/flutter_neo_shield.dart';
import 'package:flutter_neo_shield/src/log_shield/dio_shield_interceptor.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> logMessages;
  late DioShieldInterceptor interceptor;

  setUp(() {
    PIIDetector().reset();
    logMessages = [];
    interceptor = DioShieldInterceptor(
      logFunction: (msg) => logMessages.add(msg),
    );
  });

  RequestOptions makeOptions({
    String method = 'GET',
    String path = 'https://api.example.com/users',
    Map<String, dynamic>? headers,
    dynamic data,
  }) {
    return RequestOptions(
      path: path,
      method: method,
      headers: headers ?? {},
      data: data,
    );
  }

  group('DioShieldInterceptor onRequest', () {
    test('logs request method and URL', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(makeOptions(), handler);

      expect(handler.nextCalled, isTrue);
      expect(logMessages.any((m) => m.contains('GET')), isTrue);
      expect(logMessages.any((m) => m.contains('api.example.com')), isTrue);
    });

    test('sanitizes PII in URL', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(
        makeOptions(path: 'https://api.example.com/users?email=john@test.com'),
        handler,
      );

      expect(logMessages.any((m) => m.contains('[EMAIL HIDDEN]')), isTrue);
      expect(logMessages.any((m) => m.contains('john@test.com')), isFalse);
    });

    test('redacts default sensitive headers', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(
        makeOptions(headers: {
          'Authorization': 'Bearer sk-12345678abc',
          'Content-Type': 'application/json',
        }),
        handler,
      );

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
      expect(logMessages.any((m) => m.contains('application/json')), isTrue);
    });

    test('redacts custom sensitive headers', () {
      final customInterceptor = DioShieldInterceptor(
        logFunction: (msg) => logMessages.add(msg),
        sensitiveHeaders: ['x-custom-secret'],
      );
      final handler = _MockRequestHandler();
      customInterceptor.onRequest(
        makeOptions(headers: {
          'X-Custom-Secret': 'my-secret-value',
        }),
        handler,
      );

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
      expect(logMessages.any((m) => m.contains('my-secret-value')), isFalse);
    });

    test('sanitizes Map body', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(
        makeOptions(data: {
          'email': 'john@test.com',
          'id': 123,
        }),
        handler,
      );

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
    });

    test('sanitizes List body', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(
        makeOptions(data: [
          {'email': 'john@test.com'},
        ]),
        handler,
      );

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
    });

    test('sanitizes String body', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(
        makeOptions(data: 'email is john@test.com'),
        handler,
      );

      expect(logMessages.any((m) => m.contains('[EMAIL HIDDEN]')), isTrue);
    });

    test('skips body when sanitizeRequestBody is false', () {
      final noBodyInterceptor = DioShieldInterceptor(
        logFunction: (msg) => logMessages.add(msg),
        sanitizeRequestBody: false,
      );
      final handler = _MockRequestHandler();
      noBodyInterceptor.onRequest(
        makeOptions(data: {'email': 'john@test.com'}),
        handler,
      );

      expect(logMessages.any((m) => m.contains('Body:')), isFalse);
    });

    test('handler.next always called', () {
      final handler = _MockRequestHandler();
      interceptor.onRequest(makeOptions(), handler);
      expect(handler.nextCalled, isTrue);
    });
  });

  group('DioShieldInterceptor onResponse', () {
    test('logs response status code', () {
      final handler = _MockResponseHandler();
      final response = Response(
        requestOptions: makeOptions(),
        statusCode: 200,
        data: {'status': 'ok'},
      );

      interceptor.onResponse(response, handler);

      expect(handler.nextCalled, isTrue);
      expect(logMessages.any((m) => m.contains('200')), isTrue);
    });

    test('sanitizes response body map', () {
      final handler = _MockResponseHandler();
      final response = Response(
        requestOptions: makeOptions(),
        statusCode: 200,
        data: {'name': 'John Doe', 'id': 123},
      );

      interceptor.onResponse(response, handler);

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
    });

    test('sanitizes response body list', () {
      final handler = _MockResponseHandler();
      final response = Response(
        requestOptions: makeOptions(),
        statusCode: 200,
        data: [
          {'email': 'john@test.com'},
        ],
      );

      interceptor.onResponse(response, handler);

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
    });

    test('skips body when sanitizeResponseBody is false', () {
      final noBodyInterceptor = DioShieldInterceptor(
        logFunction: (msg) => logMessages.add(msg),
        sanitizeResponseBody: false,
      );
      final handler = _MockResponseHandler();
      final response = Response(
        requestOptions: makeOptions(),
        statusCode: 200,
        data: {'email': 'john@test.com'},
      );

      noBodyInterceptor.onResponse(response, handler);

      expect(logMessages.any((m) => m.contains('Body:')), isFalse);
    });

    test('handler.next always called', () {
      final handler = _MockResponseHandler();
      final response = Response(
        requestOptions: makeOptions(),
        statusCode: 200,
      );

      interceptor.onResponse(response, handler);
      expect(handler.nextCalled, isTrue);
    });
  });

  group('DioShieldInterceptor onError', () {
    test('logs error type', () {
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: makeOptions(),
        type: DioExceptionType.connectionTimeout,
        message: 'Connection timed out',
      );

      interceptor.onError(err, handler);

      expect(handler.nextCalled, isTrue);
      expect(logMessages.any((m) => m.contains('connectionTimeout')), isTrue);
    });

    test('sanitizes error message PII', () {
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: makeOptions(),
        message: 'Failed for user john@test.com',
      );

      interceptor.onError(err, handler);

      expect(logMessages.any((m) => m.contains('[EMAIL HIDDEN]')), isTrue);
    });

    test('sanitizes error response body', () {
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: makeOptions(),
        response: Response(
          requestOptions: makeOptions(),
          statusCode: 400,
          data: {'email': 'john@test.com'},
        ),
      );

      interceptor.onError(err, handler);

      expect(logMessages.any((m) => m.contains('[REDACTED]')), isTrue);
    });

    test('handler.next always called', () {
      final handler = _MockErrorHandler();
      final err = DioException(
        requestOptions: makeOptions(),
      );

      interceptor.onError(err, handler);
      expect(handler.nextCalled, isTrue);
    });
  });
}

class _MockRequestHandler extends RequestInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(RequestOptions requestOptions) {
    nextCalled = true;
  }
}

class _MockResponseHandler extends ResponseInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(Response<dynamic> response) {
    nextCalled = true;
  }
}

class _MockErrorHandler extends ErrorInterceptorHandler {
  bool nextCalled = false;

  @override
  void next(DioException err) {
    nextCalled = true;
  }
}
