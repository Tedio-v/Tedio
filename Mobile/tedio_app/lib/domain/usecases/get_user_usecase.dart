import 'package:dartz/dartz.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class GetUserUseCase {
  final UserRepository repository;

  GetUserUseCase(this.repository);

  Future<Either<Failure, User>> call(String userId) async {
    if (userId.isEmpty) {
      return const Left(ValidationFailure(
        message: 'User ID cannot be empty',
      ));
    }
    
    return await repository.getUser(userId);
  }
}