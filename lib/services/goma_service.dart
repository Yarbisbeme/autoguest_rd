import '../models/goma_model.dart';
import 'api_service.dart';

class GomaService {
  final ApiService _apiService = ApiService();

  Future<List<GomaModel>> obtenerGomas({
    required int vehiculoId,
  }) async {
    final response = await _apiService.getWithParams(
      'gomas',
      params: {
        'vehiculo_id': '$vehiculoId',
      },
    );

    print('RESPUESTA GET GOMAS: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando gomas');
    }

    final data = response['data'];

    if (data is Map && data['gomas'] is List) {
      return (data['gomas'] as List)
          .map((e) => GomaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is List) {
      return data
          .map((e) => GomaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => GomaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> actualizarEstadoGoma({
    required int gomaId,
    required String estado,
  }) async {
    final response = await _apiService.post(
      'gomas/actualizar',
      {
        'goma_id': gomaId,
        'estado': estado,
      },
    );

    print('RESPUESTA POST GOMAS/ACTUALIZAR: $response');
    return response;
  }

  Future<Map<String, dynamic>> registrarPinchazo({
    required int gomaId,
    required String descripcion,
  }) async {
    final response = await _apiService.post(
      'gomas/pinchazos',
      {
        'goma_id': gomaId,
        'descripcion': descripcion,
      },
    );

    print('RESPUESTA POST GOMAS/PINCHAZOS: $response');
    return response;
  }
}