import 'dart:convert';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../sources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final SharedPreferences sharedPreferences;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    try {
      final response = await remoteDataSource.login(email, password);
      
      if (response['success'] == true) {
        final data = response['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'];
        
        final user = User.fromJson(userData);
        
        // Store session data
        await sharedPreferences.setString('accessToken', accessToken);
        await sharedPreferences.setString('refreshToken', refreshToken);
        await sharedPreferences.setString('user_data', jsonEncode(user.toJson()));
        
        return Right(user);
      } else {
        return Left(ServerFailure(response['message'] ?? 'Login failed'));
      }
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> register(String username, String email, String password) async {
    try {
      final response = await remoteDataSource.register(username, email, password);
      
      if (response['success'] == true) {
        final data = response['data'];
        final accessToken = data['accessToken'];
        final refreshToken = data['refreshToken'];
        final userData = data['user'];
        
        final user = User.fromJson(userData);
        
        // Store session data
        await sharedPreferences.setString('accessToken', accessToken);
        await sharedPreferences.setString('refreshToken', refreshToken);
        await sharedPreferences.setString('user_data', jsonEncode(user.toJson()));
        
        return Right(user);
      } else {
        return Left(ServerFailure(response['message'] ?? 'Registration failed'));
      }
    } on ServerException catch (e) {

      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      await sharedPreferences.remove('accessToken');
      await sharedPreferences.remove('refreshToken');
      await sharedPreferences.remove('user_data');
      return const Right(true);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      final userDataStr = sharedPreferences.getString('user_data');
      if (userDataStr != null) {
        final user = User.fromJson(jsonDecode(userDataStr));
        return Right(user);
      }
      return const Left(CacheFailure('No user found'));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
