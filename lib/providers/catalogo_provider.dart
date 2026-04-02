import 'package:flutter/material.dart';
import '../models/catalogo_model.dart';
import '../services/catalogo_service.dart';


class CatalogoProvider extends ChangeNotifier {
  final CatalogoService _service = CatalogoService();

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String _errorMessage = '';

  List<CatalogoModel> _items = [];
  CatalogoModel? _detalle;

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String get errorMessage => _errorMessage;
  List<CatalogoModel> get items => _items;
  CatalogoModel? get detalle => _detalle;

  Future<void> cargarCatalogo({
    String? marca,
    String? modelo,
    String? anio,
    String? precioMin,
    String? precioMax,
    int page = 1,
    int limit = 10,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _items = await _service.obtenerCatalogo(
        marca: marca,
        modelo: modelo,
        anio: anio,
        precioMin: precioMin,
        precioMax: precioMax,
        page: page,
        limit: limit,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> cargarDetalle(int id) async {
    _isDetailLoading = true;
    _errorMessage = '';
    _detalle = null;
    notifyListeners();

    try {
      _detalle = await _service.obtenerDetalle(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void limpiar() {
    _items = [];
    _detalle = null;
    _errorMessage = '';
    notifyListeners();
  }
}