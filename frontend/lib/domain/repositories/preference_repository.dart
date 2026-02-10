import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

import '../entities/location.dart';

abstract class PreferenceRepository {
  Future<Either<Failure, bool>> syncPreferences(String userId, List<String> categories);
  Future<Either<Failure, bool>> generateSeedRecommendations();
  Future<Either<Failure, List<Location>>> getRecommendations();
  Future<Either<Failure, Location>> getRecommendationById(String id);
}
