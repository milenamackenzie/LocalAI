import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/preference_repository.dart';

import '../../domain/entities/location.dart';

class PreferenceRepositoryImpl implements PreferenceRepository {
  final ApiClient apiClient;

  PreferenceRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, bool>> syncPreferences(String userId, List<String> categories) async {
    try {
      final response = await apiClient.put(
        '/users/preferences',
        data: {
          'preferences': [
            {
              'category': 'interests',
              'value': categories,
            }
          ],
        },
      );
      return Right(response.statusCode == 200);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> generateSeedRecommendations() async {
    try {
      final response = await apiClient.post(
        '/recommendations/generate',
        data: {
          'context': 'initial_seed',
        },
      );
      return Right(response.statusCode == 201);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Location>>> getRecommendations() async {
    try {
      final response = await apiClient.get('/recommendations');
      if (response.statusCode == 200) {
        final List data = response.data['data'];
        return Right(data.map((json) => Location.fromJson(json)).toList());
      }
      return const Right([]);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Location>> getRecommendationById(String id) async {
    try {
      final response = await apiClient.get('/recommendations/$id');
      if (response.statusCode == 200) {
        return Right(Location.fromJson(response.data['data']));
      }
      return const Left(ServerFailure('Location not found'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
