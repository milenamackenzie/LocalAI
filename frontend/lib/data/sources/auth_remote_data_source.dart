import '../../core/network/api_client.dart';
import '../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<Map<String, dynamic>> login(String email, String password);
  Future<Map<String, dynamic>> register(String username, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await apiClient.post(
      AppConfig.loginEndpoint,
      data: {'email': email, 'password': password},
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<Map<String, dynamic>> register(String username, String email, String password) async {
    final response = await apiClient.post(
      AppConfig.registerEndpoint,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return response.data as Map<String, dynamic>;
  }
}
