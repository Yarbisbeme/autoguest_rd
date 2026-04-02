import 'package:flutter/material.dart';
import '../models/ingreso_model.dart';
import '../services/ingreso_service.dart';

class IngresoProvider extends ChangeNotifier {
  final IngresoService _service = IngresoService();

  bool _isLoading = false;
  bool _isCreating = false;
  String _errorMessage = '';

  List<IngresoModel> _ingresos = [];

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String get errorMessage => _errorMessage;
  List<IngresoModel> get ingresos => _ingresos;

  Future<void> cargarIngresos({
    required int vehiculoId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _ingresos = await _service.obtenerIngresos(
        vehiculoId: vehiculoId,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearIngreso({
    required int vehiculoId,
    required String concepto,
    required String monto,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await _service.crearIngreso(
        vehiculoId: vehiculoId,
        concepto: concepto,
        monto: monto,
      );

      if (res['success'] == true) {
        await cargarIngresos(vehiculoId: vehiculoId);
        _isCreating = false;
        notifyListeners();
        return true;
      }

      _errorMessage = res['message']?.toString() ?? 'Error creando ingreso';
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
}