import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';

class ApiService {
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await TokenStorage.getToken();

    return {
      'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final headers = await _getAuthHeaders();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: headers,
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getWithParams(
    String endpoint, {
    Map<String, String>? params,
  }) async {
    final headers = await _getAuthHeaders();

    final uri = Uri.parse(
      '${ApiConstants.baseUrl}/$endpoint',
    ).replace(queryParameters: params);

    final response = await http.get(uri, headers: headers);

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getAuthHeaders();

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/$endpoint'),
      headers: headers,
      body: {
        'datax': jsonEncode(body),
      },
    );

    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}