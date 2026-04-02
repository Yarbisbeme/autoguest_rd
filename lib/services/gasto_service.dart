import '../models/gasto_categoria_model.dart';
import '../models/gasto_model.dart';
import 'api_service.dart';

class GastoService {
  final ApiService _apiService = ApiService();

  Future<List<GastoCategoriaModel>> obtenerCategorias() async {
    final response = await _apiService.get('gastos/categorias');

    print('RESPUESTA GET GASTOS/CATEGORIAS: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando categorías');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => GastoCategoriaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => GastoCategoriaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<List<GastoModel>> obtenerGastos({
    required int vehiculoId,
  }) async {
    final response = await _apiService.getWithParams(
      'gastos',
      params: {
        'vehiculo_id': '$vehiculoId',
      },
    );

    print('RESPUESTA GET GASTOS: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando gastos');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => GastoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => GastoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> crearGasto({
    required int vehiculoId,
    required int categoriaId,
    required String descripcion,
    required String monto,
  }) async {
    final response = await _apiService.post(
      'gastos',
      {
        'vehiculo_id': vehiculoId,
        'categoria_id': categoriaId,
        'descripcion': descripcion,
        'monto': monto,
      },
    );

    print('RESPUESTA POST GASTOS: $response');
    return response;
  }
}