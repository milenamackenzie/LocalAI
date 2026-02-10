import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../error/exceptions.dart';

class ApiClient {
  final Dio dio;
  final SharedPreferences sharedPreferences;

  ApiClient({required this.dio, required this.sharedPreferences}) {
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
          final token = sharedPreferences.getString('accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401) {
            // Clear tokens on unauthorized
            await sharedPreferences.remove('accessToken');
            await sharedPreferences.remove('refreshToken');
            await sharedPreferences.remove('user_data');
            // TODO: In a real app, use a stream or event bus to notify AuthBloc
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
