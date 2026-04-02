import '../models/noticia_model.dart';
import 'api_service.dart';

class NoticiaService {
  final ApiService _apiService = ApiService();

  Future<List<NoticiaModel>> obtenerNoticias() async {
    final response = await _apiService.get('noticias');

    print('RESPUESTA GET NOTICIAS: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando noticias');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => NoticiaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => NoticiaModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<NoticiaModel> obtenerDetalleNoticia(int id) async {
    final response = await _apiService.getWithParams(
      'noticias/detalle',
      params: {
        'id': '$id',
      },
    );

    print('RESPUESTA GET NOTICIAS/DETALLE: $response');

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Error cargando detalle de noticia');
    }

    return NoticiaModel.fromJson(
      Map<String, dynamic>.from(response['data'] ?? {}),
    );
  }

  Future<String> obtenerImagenPreview(int id) async {
    final detalle = await obtenerDetalleNoticia(id);
    return detalle.imagen;
  }
}