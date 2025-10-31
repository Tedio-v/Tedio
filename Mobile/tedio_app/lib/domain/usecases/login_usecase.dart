import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/user_repository.dart';

class LoginUseCase {
  final UserRepository repository;

  LoginUseCase(this.repository);

  Future<Either<Failure, User>> call(LoginParams params) async {
    if (params.email.isEmpty || params.password.isEmpty) {
      return const Left(ValidationFailure(
        message: 'Email and password cannot be empty',
      ));
    }
    
    if (!_isValidEmail(params.email)) {
      return const Left(ValidationFailure(
        message: 'Please enter a valid email address',
      ));
    }
    
    return await repository.login(params.email, params.password);
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}

class LoginParams extends Equatable {
  final String email;
  final String password;

  const LoginParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}