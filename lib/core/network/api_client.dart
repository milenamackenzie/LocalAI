import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio) {
    dio.options.baseUrl = AppConfig.baseUrl;
    dio.options.connectTimeout = const Duration(milliseconds: AppConfig.connectTimeout);
    dio.options.receiveTimeout = const Duration(milliseconds: AppConfig.receiveTimeout);

    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // TODO: Get token from secure storage and add to header
          // options.headers['Authorization'] = 'Bearer $token';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            // TODO: Handle token expiration (e.g., refresh or logout)
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    try {
      return await dio.get(path, queryParameters: queryParameters);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Server Error');
    }
  }

  Future<Response> post(String path, {dynamic data}) async {
    try {
      return await dio.post(path, data: data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Server Error');
    }
  }

  Future<Response> put(String path, {dynamic data}) async {
    try {
      return await dio.put(path, data: data);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Server Error');
    }
  }

  Future<Response> delete(String path) async {
    try {
      return await dio.delete(path);
    } on DioException catch (e) {
      throw ServerException(e.response?.data['message'] ?? 'Server Error');
    }
  }
}
