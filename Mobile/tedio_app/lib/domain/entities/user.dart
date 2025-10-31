import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profilePicture;
  final String? phoneNumber;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.profilePicture,
    this.phoneNumber,
    this.createdAt,
    this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        profilePicture,
        phoneNumber,
        createdAt,
        updatedAt,
      ];
}