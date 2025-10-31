import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/user_repository.dart';
import '../datasources/local/local_storage.dart';

class UserRepositoryImpl implements UserRepository {
  final LocalStorage localStorage;

  UserRepositoryImpl({
    required this.localStorage,
  });

  @override
  Future<Either<Failure, User>> getUser(String userId) async {
    try {
      // For Tedio app, we don't have a getUser endpoint
      // Return cached user if available
      final cachedUser = localStorage.getUser();
      if (cachedUser != null) {
        return Right(cachedUser);
      }
      return const Left(ServerFailure(message: 'User not found'));
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(NetworkFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login(String email, String password) async {
    // This is handled by AuthService in the Tedio app
    return const Left(ServerFailure(message: 'Use AuthService for login'));
  }

  @override
  Future<Either<Failure, List<User>>> getUsers() async {
    // Not needed for Tedio app
    return const Left(ServerFailure(message: 'Not implemented'));
  }

  @override
  Future<Either<Failure, User?>> getCachedUser() async {
    try {
      final user = localStorage.getUser();
      return Right(user);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await localStorage.clearAuth();
      return Right(result);
    } catch (e) {
      return Left(CacheFailure(message: e.toString()));
    }
  }
}