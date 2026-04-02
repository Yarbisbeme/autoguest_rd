import 'package:flutter/material.dart';
import '../models/gasto_categoria_model.dart';
import '../models/gasto_model.dart';
import '../services/gasto_service.dart';

class GastoProvider extends ChangeNotifier {
  final GastoService _service = GastoService();

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isLoadingCategorias = false;
  String _errorMessage = '';

  List<GastoModel> _gastos = [];
  List<GastoCategoriaModel> _categorias = [];

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isLoadingCategorias => _isLoadingCategorias;
  String get errorMessage => _errorMessage;
  List<GastoModel> get gastos => _gastos;
  List<GastoCategoriaModel> get categorias => _categorias;

  Future<void> cargarCategorias() async {
    _isLoadingCategorias = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _categorias = await _service.obtenerCategorias();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoadingCategorias = false;
      notifyListeners();
    }
  }

  Future<void> cargarGastos({
    required int vehiculoId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _gastos = await _service.obtenerGastos(vehiculoId: vehiculoId);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearGasto({
    required int vehiculoId,
    required int categoriaId,
    required String descripcion,
    required String monto,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final res = await _service.crearGasto(
        vehiculoId: vehiculoId,
        categoriaId: categoriaId,
        descripcion: descripcion,
        monto: monto,
      );

      if (res['success'] == true) {
        await cargarGastos(vehiculoId: vehiculoId);
        _isCreating = false;
        notifyListeners();
        return true;
      }

      _errorMessage = res['message']?.toString() ?? 'Error creando gasto';
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
String obtenerNombreCategoria(int? categoriaId, String categoriaNombreActual) {
  if (categoriaNombreActual.trim().isNotEmpty) {
    return categoriaNombreActual;
  }

  if (categoriaId == null) return 'Sin categoría';

  try {
    final categoria = _categorias.firstWhere((c) => c.id == categoriaId);
    return categoria.nombre.isNotEmpty ? categoria.nombre : 'Sin categoría';
  } catch (_) {
    return 'Sin categoría';
  }
}
  void limpiar() {
    _gastos = [];
    _categorias = [];
    _errorMessage = '';
    notifyListeners();
  }
}