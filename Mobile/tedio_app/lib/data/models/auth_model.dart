class AuthResponse {
  final String token;
  final UserData user;

  AuthResponse({
    required this.token,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      token: json['token'] ?? '',
      user: UserData.fromJson(json['user'] ?? {}),
    );
  }
}

class UserData {
  final String id;
  final String email;
  final String childName;
  final int? childAge;
  final bool firstLogin;

  UserData({
    required this.id,
    required this.email,
    required this.childName,
    this.childAge,
    required this.firstLogin,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    // Handle child_age which can be null, string, or int
    int? age;
    if (json['child_age'] != null) {
      if (json['child_age'] is int) {
        age = json['child_age'];
      } else if (json['child_age'] is String) {
        age = int.tryParse(json['child_age']);
      }
    }
    
    return UserData(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      childName: json['child_name'] ?? '',
      childAge: age,
      firstLogin: json['first_login'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'child_name': childName,
      if (childAge != null) 'child_age': childAge,
      'first_login': firstLogin,
    };
  }
}