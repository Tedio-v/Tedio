import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> getUser(String userId);
  Future<Either<Failure, User>> login(String email, String password);
  Future<Either<Failure, List<User>>> getUsers();
  Future<Either<Failure, User?>> getCachedUser();
  Future<Either<Failure, bool>> logout();
}