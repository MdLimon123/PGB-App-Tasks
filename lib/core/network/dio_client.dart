import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/api_constants.dart';

class DioClient {
  final Dio dio;
  final FlutterSecureStorage secureStorage;
  
  // Prevent multiple token refresh attempts
  bool _isRefreshing = false;

  DioClient({required this.dio, required this.secureStorage}) {
    _initializeDio();
  }

  void _initializeDio() {
    dio.options.baseUrl = ApiConstants.baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    dio.options.contentType = 'application/json';

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await secureStorage.read(key: 'access_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            return _handleUnauthorized(e, handler);
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<dynamic> _handleUnauthorized(DioException error, ErrorInterceptorHandler handler) async {
    final RequestOptions requestOptions = error.requestOptions;

    if (!_isRefreshing) {
      _isRefreshing = true;
      try {
        final refreshToken = await secureStorage.read(key: 'refresh_token');
        if (refreshToken != null) {
          final response = await dio.post(
            ApiConstants.refresh,
            data: {'refresh_token': refreshToken},
          );

          final newAccessToken = response.data['access_token'];
          await secureStorage.write(key: 'access_token', value: newAccessToken);

          _isRefreshing = false;
          
          // Retry original request
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          return handler.resolve(await dio.request<dynamic>(
            requestOptions.path,
            cancelToken: requestOptions.cancelToken,
            data: requestOptions.data,
            onReceiveProgress: requestOptions.onReceiveProgress,
            onSendProgress: requestOptions.onSendProgress,
            queryParameters: requestOptions.queryParameters,
            options: Options(
              method: requestOptions.method,
              headers: requestOptions.headers,
            ),
          ));
        }
      } catch (e) {
        _isRefreshing = false;
        await secureStorage.delete(key: 'access_token');
        await secureStorage.delete(key: 'refresh_token');
      }
    }

    return handler.next(error);
  }
}
