import '../models/combustible_model.dart';
import 'api_service.dart';

class CombustibleService {
  final ApiService _apiService = ApiService();

  Future<List<CombustibleModel>> obtenerCombustibles({
    required int vehiculoId,
  }) async {
    final response = await _apiService.getWithParams(
      'combustibles',
      params: {
        'vehiculo_id': '$vehiculoId',
      },
    );

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'No se pudieron cargar los combustibles',
      );
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map(
            (e) => CombustibleModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map(
            (e) => CombustibleModel.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> crearCombustible({
    required int vehiculoId,
    required String tipo,
    required String cantidad,
    required String unidad,
    required String monto,
  }) async {
    final response = await _apiService.post(
      'combustibles',
      {
        'vehiculo_id': vehiculoId,
        'tipo': tipo,
        'cantidad': cantidad,
        'unidad': unidad,
        'monto': monto,
      },
    );

    return response;
  }
}