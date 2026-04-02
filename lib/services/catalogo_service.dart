import '../models/catalogo_model.dart';
import 'api_service.dart';

class CatalogoService {
  final ApiService _apiService = ApiService();

  Future<List<CatalogoModel>> obtenerCatalogo({
    String? marca,
    String? modelo,
    String? anio,
    String? precioMin,
    String? precioMax,
    int page = 1,
    int limit = 10,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
    };

    if (marca != null && marca.isNotEmpty) {
      params['marca'] = marca;
    }

    if (modelo != null && modelo.isNotEmpty) {
      params['modelo'] = modelo;
    }

    if (anio != null && anio.isNotEmpty) {
      params['anio'] = anio;
    }

    if (precioMin != null && precioMin.isNotEmpty) {
      params['precioMin'] = precioMin;
    }

    if (precioMax != null && precioMax.isNotEmpty) {
      params['precioMax'] = precioMax;
    }

    final response = await _apiService.getWithParams(
      'catalogo',
      params: params,
    );

    print('RESPUESTA GET CATALOGO: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando catálogo');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => CatalogoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => CatalogoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<CatalogoModel> obtenerDetalle(int id) async {
    final response = await _apiService.getWithParams(
      'catalogo/detalle',
      params: {'id': '$id'},
    );

    print('RESPUESTA GET CATALOGO/DETALLE: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando detalle');
    }

    return CatalogoModel.fromJson(
      Map<String, dynamic>.from(response['data'] ?? {}),
    );
  }
}