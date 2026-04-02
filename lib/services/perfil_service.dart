import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/perfil_model.dart';
import 'api_service.dart';

class PerfilService {
  final ApiService _apiService = ApiService();

  Future<PerfilModel> obtenerPerfil() async {
    final response = await _apiService.get('perfil');

    print('RESPUESTA GET PERFIL: $response');

    if (response['success'] == true && response['data'] != null) {
      return PerfilModel.fromJson(
        Map<String, dynamic>.from(response['data']),
      );
    }

    throw Exception(response['message'] ?? 'No se pudo obtener el perfil');
  }

  Future<Map<String, dynamic>> cambiarFotoPerfil({
    required File foto,
  }) async {
    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/perfil/foto'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files.add(
      await http.MultipartFile.fromPath('foto', foto.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    print('RESPUESTA POST PERFIL/FOTO: $data');

    return data;
  }
}