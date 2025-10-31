import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/auth_model.dart';

class AuthService {
  final http.Client client;
  
  AuthService({http.Client? client}) : client = client ?? http.Client();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.loginEndpoint}'),
        headers: ApiConstants.headers,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return AuthResponse.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Invalid email or password');
      } else {
        throw Exception('Login failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String childName,
    int? childAge,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'child_name': childName,
      };
      
      if (childAge != null) {
        body['child_age'] = childAge;
      }
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.registerEndpoint}'),
        headers: ApiConstants.headers,
        body: json.encode(body),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 201) {
        final jsonData = json.decode(response.body);
        return AuthResponse.fromJson(jsonData);
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      } else {
        throw Exception('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> completeOnboarding(String token) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.completeOnboardingEndpoint}'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to complete onboarding');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}