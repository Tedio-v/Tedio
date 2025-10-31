import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class QuickActionService {
  final http.Client client;

  QuickActionService({http.Client? client}) : client = client ?? http.Client();

  Future<List<String>> getCompletedActions(String token) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';

      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}/quick-actions/completed'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<String>.from(jsonData['completed_actions'] ?? []);
      } else {
        throw Exception('Failed to load completed actions');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> completeQuickAction(String token, String actionId) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';

      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/quick-actions/complete'),
        headers: headers,
        body: json.encode({'actionId': actionId}),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to complete action');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> uncompleteQuickAction(String token, String actionId) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';

      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}/quick-actions/uncomplete'),
        headers: headers,
        body: json.encode({'actionId': actionId}),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to uncomplete action');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}