import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';

class AuthService {
  Future<Map<String, dynamic>> registro({
    required String matricula,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/registro'),
      body: {
        'datax': jsonEncode({
          'matricula': matricula,
        }),
      },
    );

    final data = jsonDecode(response.body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> activar({
    required String tokenTemporal,
    required String contrasena,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/activar'),
      body: {
        'datax': jsonEncode({
          'token': tokenTemporal,
          'contrasena': contrasena,
        }),
      },
    );

    final data = jsonDecode(response.body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> login({
    required String matricula,
    required String contrasena,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/login'),
      body: {
        'datax': jsonEncode({
          'matricula': matricula,
          'contrasena': contrasena,
        }),
      },
    );

    final data = jsonDecode(response.body);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> olvidarContrasena({
    required String matricula,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/auth/olvidar'),
      body: {
        'datax': jsonEncode({
          'matricula': matricula,
        }),
      },
    );

    final data = jsonDecode(response.body);
    print('RESPUESTA POST AUTH/OLVIDAR: $data');
    return Map<String, dynamic>.from(data);
  }
}