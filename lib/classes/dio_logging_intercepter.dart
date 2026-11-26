import 'package:dio/dio.dart';
import 'package:lit_reader/env/global.dart';

class DioLoggingInterceptor extends Interceptor {
  // Logging must never break a request: anything thrown inside an interceptor
  // is turned by Dio into a DioException and fails the whole call.
  void _log(String message) {
    try {
      logController.addLog(message);
    } catch (_) {}
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (options.method == 'POST' || options.method == 'GET') {
      _log('Request [${options.method}] => URL: ${options.uri}');
      _log('Headers: ${options.headers}');
      _log('Data: ${options.data}');
    }
    handler.next(options); // Continue with the request
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (response.requestOptions.method == 'POST' || response.requestOptions.method == 'GET') {
      _log('Response [${response.requestOptions.method}] => URL: ${response.requestOptions.uri}');
      _log('Status Code: ${response.statusCode}');
      _log('Data: ${response.data}');
    }
    handler.next(response); // Continue with the response
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.requestOptions.method == 'POST' || err.requestOptions.method == 'GET') {
      _log('Error [${err.requestOptions.method}] => URL: ${err.requestOptions.uri}');
      _log('Error: ${err.error}');
      _log('Response Data: ${err.response?.data}');
    }
    handler.next(err); // Continue with the error
  }
}
