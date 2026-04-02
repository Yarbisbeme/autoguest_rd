import 'package:flutter/material.dart';
import '../models/combustible_model.dart';
import '../services/combustible_service.dart';

class CombustibleProvider extends ChangeNotifier {
  final CombustibleService _combustibleService = CombustibleService();

  bool _isLoading = false;
  bool _isCreating = false;
  String _errorMessage = '';
  List<CombustibleModel> _combustibles = [];

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String get errorMessage => _errorMessage;
  List<CombustibleModel> get combustibles => _combustibles;

  Future<void> cargarCombustibles({
    required int vehiculoId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _combustibles = await _combustibleService.obtenerCombustibles(
        vehiculoId: vehiculoId,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearCombustible({
    required int vehiculoId,
    required String tipo,
    required String cantidad,
    required String unidad,
    required String monto,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _combustibleService.crearCombustible(
        vehiculoId: vehiculoId,
        tipo: tipo,
        cantidad: cantidad,
        unidad: unidad,
        monto: monto,
      );

      if (response['success'] == true) {
        await cargarCombustibles(vehiculoId: vehiculoId);
        _isCreating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          response['message']?.toString() ?? 'No se pudo registrar el combustible';
      _isCreating = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isCreating = false;
      notifyListeners();
      return false;
    }
  }

  void limpiar() {
    _combustibles = [];
    _errorMessage = '';
    notifyListeners();
  }
}