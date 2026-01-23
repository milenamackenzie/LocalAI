import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';

abstract class PreferenceRepository {
  Future<Either<Failure, bool>> syncPreferences(String userId, List<String> categories);
}
