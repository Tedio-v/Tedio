import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/auth_model.dart';

class UserService {
  final http.Client client;

  UserService({http.Client? client}) : client = client ?? http.Client();

  Future<UserData> getUserSettings(String token) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';

      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}/settings'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return UserData.fromJson(jsonData);
      } else if (response.statusCode == 401) {
        throw Exception('Authentication required');
      } else {
        throw Exception('Failed to load user settings');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> updateUserSettings(String token, Map<String, dynamic> updates) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';

      final response = await client.put(
        Uri.parse('${ApiConstants.baseUrl}/settings'),
        headers: headers,
        body: json.encode(updates),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        final error = json.decode(response.body);
        throw Exception(error['error'] ?? 'Failed to update settings');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}