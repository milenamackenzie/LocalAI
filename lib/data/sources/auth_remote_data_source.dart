import '../../core/network/api_client.dart';
import '../../core/config/app_config.dart';

abstract class AuthRemoteDataSource {
  Future<bool> login(String email, String password);
  Future<bool> register(String username, String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<bool> login(String email, String password) async {
    final response = await apiClient.post(
      AppConfig.loginEndpoint,
      data: {'email': email, 'password': password},
    );
    return response.statusCode == 200;
  }

  @override
  Future<bool> register(String username, String email, String password) async {
    final response = await apiClient.post(
      AppConfig.registerEndpoint,
      data: {
        'username': username,
        'email': email,
        'password': password,
      },
    );
    return response.statusCode == 201;
  }
}
