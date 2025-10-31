import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../../core/errors/failures.dart';

class ApiService {
  final http.Client client;
  
  ApiService({http.Client? client}) : client = client ?? http.Client();

  Future<Map<String, String>> _getHeaders({String? token}) async {
    final headers = Map<String, String>.from(ApiConstants.headers);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, dynamic>> makeRequest({
    required String method,
    required String endpoint,
    Map<String, dynamic>? body,
    String? token,
    Duration? timeout,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}$endpoint');
      final headers = await _getHeaders(token: token);
      
      http.Response response;
      
      switch (method.toUpperCase()) {
        case 'GET':
          response = await client.get(uri, headers: headers)
              .timeout(timeout ?? ApiConstants.connectionTimeout);
          break;
        case 'POST':
          response = await client.post(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout ?? ApiConstants.connectionTimeout);
          break;
        case 'PUT':
          response = await client.put(
            uri,
            headers: headers,
            body: body != null ? json.encode(body) : null,
          ).timeout(timeout ?? ApiConstants.connectionTimeout);
          break;
        case 'DELETE':
          response = await client.delete(uri, headers: headers)
              .timeout(timeout ?? ApiConstants.connectionTimeout);
          break;
        default:
          throw Exception('Unsupported HTTP method: $method');
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          return {};
        }
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        throw const AuthenticationFailure(
          message: 'Unauthorized access. Please login again.',
          code: '401',
        );
      } else if (response.statusCode == 404) {
        throw const ServerFailure(
          message: 'Resource not found',
          code: '404',
        );
      } else {
        String errorMessage = 'Server error: ${response.statusCode}';
        try {
          final errorBody = json.decode(response.body);
          errorMessage = errorBody['message'] ?? errorMessage;
        } catch (_) {}
        
        throw ServerFailure(
          message: errorMessage,
          code: response.statusCode.toString(),
        );
      }
    } catch (e) {
      if (e is Failure) {
        rethrow;
      }
      print('API Service Error: ${e.toString()}');
      print('Request details: $method ${ApiConstants.baseUrl}$endpoint');
      
      if (e.toString().contains('TimeoutException')) {
        throw NetworkFailure(
          message: 'Request timeout. Please check your internet connection.',
        );
      } else if (e.toString().contains('SocketException')) {
        throw NetworkFailure(
          message: 'Unable to connect to server. Please check your internet connection.',
        );
      } else if (e.toString().contains('HandshakeException')) {
        throw NetworkFailure(
          message: 'SSL connection error. Please try again.',
        );
      } else {
        throw NetworkFailure(
          message: 'Network error: ${e.toString()}',
        );
      }
    }
  }
}