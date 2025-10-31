import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/insight_model.dart';

class InsightsService {
  final http.Client client;
  
  InsightsService({http.Client? client}) : client = client ?? http.Client();

  Future<List<InsightModel>> getInsights(String token) async {
    try {
      print('Getting insights from: ${ApiConstants.baseUrl}${ApiConstants.insightsEndpoint}');
      
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      print('Request headers: $headers');
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.insightsEndpoint}'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // Backend returns insights as a direct array, not wrapped in an object
        final List<dynamic> insights = jsonData is List ? jsonData : (jsonData['insights'] ?? []);
        return insights.map((json) => InsightModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to fetch insights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<InsightModel> getInsightById(String token, String insightId) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.get(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.insightsEndpoint}/$insightId'),
        headers: headers,
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return InsightModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to fetch insight: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> generateInsights(String token) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.generateInsightsEndpoint}'),
        headers: headers,
      ).timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        throw Exception('Failed to generate insights: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }

  Future<void> rateInsight(String token, String insightId, int rating) async {
    try {
      final headers = Map<String, String>.from(ApiConstants.headers);
      headers['Authorization'] = 'Bearer $token';
      
      final response = await client.post(
        Uri.parse('${ApiConstants.baseUrl}${ApiConstants.insightsEndpoint}/$insightId/rating'),
        headers: headers,
        body: json.encode({'rating': rating}),
      ).timeout(ApiConstants.connectionTimeout);

      if (response.statusCode != 200) {
        throw Exception('Failed to rate insight: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}