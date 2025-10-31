abstract class Failure {
  final String message;
  final String? code;
  
  const Failure({required this.message, this.code});
}

class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.code});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.code});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.code});
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message, super.code});
}