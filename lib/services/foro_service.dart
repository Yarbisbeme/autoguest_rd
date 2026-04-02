import 'api_service.dart';

class ForoService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> obtenerTemas() async {
    final response = await _apiService.get('foro/temas');
    print('RESPUESTA GET FORO/TEMAS: $response');
    return response;
  }

  Future<Map<String, dynamic>> crearTema({
    required int vehiculoId,
    required String titulo,
    required String descripcion,
  }) async {
    final response = await _apiService.post(
      'foro/crear',
      {
        'vehiculo_id': vehiculoId,
        'titulo': titulo,
        'descripcion': descripcion,
      },
    );

    print('DATA ENVIADA FORO/CREAR: {'
        '"vehiculo_id": $vehiculoId, '
        '"titulo": "$titulo", '
        '"descripcion": "$descripcion"}');
    print('RESPUESTA POST FORO/CREAR: $response');

    return response;
  }

  Future<Map<String, dynamic>> obtenerDetalle({
    required int id,
  }) async {
    final response = await _apiService.getWithParams(
      'foro/detalle',
      params: {
        'id': '$id',
      },
    );

    print('RESPUESTA GET FORO/DETALLE: $response');
    return response;
  }

  Future<Map<String, dynamic>> responderTema({
    required int temaId,
    required String contenido,
  }) async {
    final response = await _apiService.post(
      'foro/responder',
      {
        'tema_id': temaId,
        'contenido': contenido,
      },
    );

    print('DATA ENVIADA FORO/RESPONDER: {'
        '"tema_id": $temaId, '
        '"contenido": "$contenido"}');
    print('RESPUESTA POST FORO/RESPONDER: $response');

    return response;
  }

  Future<Map<String, dynamic>> obtenerMisTemas({
    int page = 1,
    int limit = 10,
  }) async {
    final response = await _apiService.getWithParams(
      'foro/mis-temas',
      params: {
        'page': '$page',
        'limit': '$limit',
      },
    );

    print('RESPUESTA GET FORO/MIS-TEMAS: $response');
    return response;
  }
}