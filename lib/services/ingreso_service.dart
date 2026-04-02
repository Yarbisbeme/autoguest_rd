import '../models/ingreso_model.dart';
import 'api_service.dart';

class IngresoService {
  final ApiService _apiService = ApiService();

  Future<List<IngresoModel>> obtenerIngresos({
    required int vehiculoId,
  }) async {
    final response = await _apiService.getWithParams(
      'ingresos',
      params: {
        'vehiculo_id': '$vehiculoId',
      },
    );

    print('RESPUESTA GET INGRESOS: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando ingresos');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => IngresoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => IngresoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> crearIngreso({
    required int vehiculoId,
    required String concepto,
    required String monto,
  }) async {
    final response = await _apiService.post(
      'ingresos',
      {
        'vehiculo_id': vehiculoId,
        'concepto': concepto,
        'monto': monto,
      },
    );

    print('RESPUESTA POST INGRESOS: $response');
    return response;
  }
}