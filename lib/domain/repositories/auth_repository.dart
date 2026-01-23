import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login(String username, String password);
  Future<Either<Failure, User>> register(String username, String email, String password);
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, User>> getCurrentUser();
}
