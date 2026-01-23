import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ApiClient apiClient;

  AuthRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, User>> login(String username, String password) async {
    try {
      final response = await apiClient.post('/auth/login', data: {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final userData = response.data['user'];
        final user = User.fromJson(userData);
        // TODO: Store auth token
        return Right(user);
      } else {
        return Left(ServerFailure('Invalid credentials'));
      }
    } on ServerException {
      return Left(ServerFailure('Server error'));
    }
  }

  @override
  Future<Either<Failure, User>> register(String username, String email, String password) async {
    try {
      final response = await apiClient.post('/auth/register', data: {
        'username': username,
        'email': email,
        'password': password,
      });

      if (response.statusCode == 201) {
        final userData = response.data['user'];
        final user = User.fromJson(userData);
        // TODO: Store auth token
        return Right(user);
      } else {
        return Left(ServerFailure('Registration failed'));
      }
    } on ServerException {
      return Left(ServerFailure('Server error'));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    // TODO: Clear auth token
    return const Right(true);
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    // TODO: Retrieve current user from stored token
    // For now, return a mock user if logged in
    // This should check local storage for token and fetch user data
    return Left(CacheFailure('Not implemented'));
  }
}
  }

  @override
  Future<Either<Failure, bool>> register(String username, String email, String password) async {
    try {
      final result = await remoteDataSource.register(username, email, password);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
