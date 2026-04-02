import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/mantenimiento_model.dart';
import 'api_service.dart';

class MantenimientoService {
  final ApiService _apiService = ApiService();

  Future<List<MantenimientoModel>> obtenerMantenimientos({
    required int vehiculoId,
  }) async {
    final response = await _apiService.getWithParams(
      'mantenimientos',
      params: {
        'vehiculo_id': '$vehiculoId',
      },
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'No se pudieron cargar los mantenimientos',
      );
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (e) => MantenimientoModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map(
            (e) => MantenimientoModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> crearMantenimiento({
    required int vehiculoId,
    required String tipo,
    required String descripcion,
    required String costo,
    List<File>? fotos,
  }) async {
    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/mantenimientos'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['datax'] = jsonEncode({
      'vehiculo_id': vehiculoId,
      'tipo': tipo,
      'descripcion': descripcion,
      'costo': costo,
    });

    if (fotos != null && fotos.isNotEmpty) {
      for (final foto in fotos) {
        request.files.add(
          await http.MultipartFile.fromPath('fotos[]', foto.path),
        );
      }
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }
}