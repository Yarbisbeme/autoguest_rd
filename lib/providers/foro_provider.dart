import 'package:flutter/material.dart';
import '../services/foro_service.dart';

class ForoProvider extends ChangeNotifier {
  final ForoService _service = ForoService();

  bool _isLoading = false;
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<dynamic> _temas = [];
  Map<String, dynamic>? _temaDetalle;
  List<dynamic> _misTemas = [];

  bool get isLoading => _isLoading;
  bool get isSubmitting => _isSubmitting;
  String get errorMessage => _errorMessage;
  List<dynamic> get temas => _temas;
  Map<String, dynamic>? get temaDetalle => _temaDetalle;
  List<dynamic> get misTemas => _misTemas;

  Future<void> cargarTemas() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.obtenerTemas();

      if (response['success'] == true) {
        final data = response['data'];

        if (data is List) {
          _temas = data;
        } else if (data is Map && data['data'] is List) {
          _temas = List<dynamic>.from(data['data']);
        } else {
          _temas = [];
        }
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Error cargando temas';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> crearTema({
    required int vehiculoId,
    required String titulo,
    required String descripcion,
  }) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.crearTema(
        vehiculoId: vehiculoId,
        titulo: titulo,
        descripcion: descripcion,
      );

      if (response['success'] == true) {
        await cargarTemas();
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Error creando tema';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarDetalle({
    required int id,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _temaDetalle = null;
    notifyListeners();

    try {
      final response = await _service.obtenerDetalle(id: id);

      if (response['success'] == true) {
        _temaDetalle = Map<String, dynamic>.from(response['data'] ?? {});
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Error cargando detalle';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> responderTema({
    required int temaId,
    required String contenido,
  }) async {
    _isSubmitting = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.responderTema(
        temaId: temaId,
        contenido: contenido,
      );

      if (response['success'] == true) {
        await cargarDetalle(id: temaId);
        _isSubmitting = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Error publicando respuesta';
        _isSubmitting = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSubmitting = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cargarMisTemas({
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _service.obtenerMisTemas(
        page: page,
        limit: limit,
      );

      if (response['success'] == true) {
        final data = response['data'];

        if (data is List) {
          _misTemas = data;
        } else if (data is Map && data['data'] is List) {
          _misTemas = List<dynamic>.from(data['data']);
        } else {
          _misTemas = [];
        }
      } else {
        _errorMessage =
            response['message']?.toString() ?? 'Error cargando mis temas';
      }
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }

    _isLoading = false;
    notifyListeners();
  }

  void limpiarDetalle() {
    _temaDetalle = null;
    notifyListeners();
  }
}