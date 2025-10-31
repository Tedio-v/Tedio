import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';

class YouTubeHistoryService {
  final http.Client client;
  
  YouTubeHistoryService({http.Client? client}) : client = client ?? http.Client();

  Future<bool> uploadHistory(String token, List<Map<String, dynamic>> history) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.youtubeHistoryEndpoint}'),
        headers: headers,
        body: json.encode({'history': history}),
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to upload history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<bool> checkHistoryStatus(String token) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.youtubeHistoryStatusEndpoint}'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return jsonData['has_data'] ?? false;
      } else {
        throw Exception('Failed to check history status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<List<Map<String, dynamic>>> getHistory(String token) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.youtubeHistoryEndpoint}'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return List<Map<String, dynamic>>.from(jsonData['history'] ?? []);
      } else {
        throw Exception('Failed to fetch history: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}