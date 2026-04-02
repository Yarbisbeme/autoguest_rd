import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/api_constants.dart';
import '../core/storage/token_storage.dart';
import '../models/vehiculo_model.dart';
import 'api_service.dart';

class VehiculoService {
  final ApiService _apiService = ApiService();

  Future<List<VehiculoModel>> obtenerVehiculos({
    String? marca,
    int page = 1,
  }) async {
    final params = <String, String>{
      'page': '$page',
    };

    if (marca != null && marca.trim().isNotEmpty) {
      params['marca'] = marca.trim();
    }

    final response = await _apiService.getWithParams(
      'vehiculos',
      params: params,
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'No se pudieron cargar los vehículos');
    }

    final data = response['data'];

    if (data is List) {
      return data
          .map((e) => VehiculoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    if (data is Map && data['data'] is List) {
      return (data['data'] as List)
          .map((e) => VehiculoModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }

    return [];
  }

  Future<Map<String, dynamic>> crearVehiculo({
    required String placa,
    required String chasis,
    required String marca,
    required String modelo,
    required String anio,
    required String cantidadRuedas,
    File? foto,
  }) async {
    final token = await TokenStorage.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiConstants.baseUrl}/vehiculos'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.fields['datax'] = jsonEncode({
      'placa': placa,
      'chasis': chasis,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'cantidadRuedas': cantidadRuedas,
    });

    if (foto != null) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', foto.path),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data;
  }

  Future<Map<String, dynamic>> obtenerVehiculoDetalle(int id) async {
    final response = await _apiService.getWithParams(
      'vehiculos/detalle',
      params: {
        'id': '$id',
      },
    );

    print('RESPUESTA DETALLE VEHICULO: $response');

    if (response['success'] != true) {
      throw Exception(
        response['message'] ?? 'No se pudo obtener el detalle del vehículo',
      );
    }

    return Map<String, dynamic>.from(response['data'] ?? {});
  }

 Future<Map<String, dynamic>> editarVehiculo({
  required int id,
  required String placa,
  required String chasis,
  required String marca,
  required String modelo,
  required String anio,
  required String cantidadRuedas,
}) async {
  final response = await _apiService.post(
    'vehiculos/editar',
    {
      'id': id,
      'placa': placa,
      'chasis': chasis,
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'cantidadRuedas': cantidadRuedas,
    },
  );

    print('RESPUESTA POST VEHICULOS/EDITAR: $response');
    return response;
  }

Future<Map<String, dynamic>> cambiarFotoVehiculo({
  required int vehiculoId,
  required File foto,
}) async {
  final token = await TokenStorage.getToken();

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('${ApiConstants.baseUrl}/vehiculos/foto'),
  );

  request.headers['Authorization'] = 'Bearer $token';

  request.fields['datax'] = jsonEncode({
    'id': vehiculoId,
  });

  request.files.add(
    await http.MultipartFile.fromPath('foto', foto.path),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  final data = jsonDecode(response.body) as Map<String, dynamic>;

  print('DATA ENVIADA A VEHICULOS/FOTO: {"id": $vehiculoId}');
  print('RESPUESTA POST VEHICULOS/FOTO: $data');

  return data;
}
}