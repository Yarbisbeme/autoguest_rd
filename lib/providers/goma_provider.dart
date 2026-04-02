import 'package:flutter/material.dart';
import '../models/goma_model.dart';
import '../services/goma_service.dart';

class GomaProvider extends ChangeNotifier {
  final GomaService _service = GomaService();

  bool _isLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';
  List<GomaModel> _gomas = [];

  bool get isLoading => _isLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  List<GomaModel> get gomas => _gomas;

  Future<void> cargarGomas(int vehiculoId) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _gomas = await _service.obtenerGomas(vehiculoId: vehiculoId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> actualizarEstadoGoma({
    required int vehiculoId,
    required int gomaId,
    required String estado,
  }) async {
    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await _service.actualizarEstadoGoma(
        gomaId: gomaId,
        estado: estado,
      );

      if (res['success'] == true) {
        await cargarGomas(vehiculoId);
        _isUpdating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          res['message']?.toString() ?? 'Error actualizando la goma';
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrarPinchazo({
    required int vehiculoId,
    required int gomaId,
    required String descripcion,
  }) async {
    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await _service.registrarPinchazo(
        gomaId: gomaId,
        descripcion: descripcion,
      );

      if (res['success'] == true) {
        await cargarGomas(vehiculoId);
        _isUpdating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          res['message']?.toString() ?? 'Error registrando pinchazo';
      _isUpdating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isUpdating = false;
      notifyListeners();
      return false;
    }
  }

  void limpiar() {
    _gomas = [];
    _errorMessage = '';
    notifyListeners();
  }
}