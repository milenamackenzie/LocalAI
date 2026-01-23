import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../domain/repositories/preference_repository.dart';

class PreferenceRepositoryImpl implements PreferenceRepository {
  final ApiClient apiClient;

  PreferenceRepositoryImpl({required this.apiClient});

  @override
  Future<Either<Failure, bool>> syncPreferences(String userId, List<String> categories) async {
    try {
      final response = await apiClient.put(
        '/users/preferences',
        data: {
          'userId': userId,
          'categories': categories,
        },
      );
      return Right(response.statusCode == 200);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
