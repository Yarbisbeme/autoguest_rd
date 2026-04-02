import 'package:flutter/material.dart';
import '../models/noticia_model.dart';
import '../services/noticia_service.dart';

class NoticiaProvider extends ChangeNotifier {
  final NoticiaService _service = NoticiaService();

  bool _isLoading = false;
  bool _isDetailLoading = false;
  String _errorMessage = '';

  List<NoticiaModel> _noticias = [];
  NoticiaModel? _noticiaDetalle;

  bool get isLoading => _isLoading;
  bool get isDetailLoading => _isDetailLoading;
  String get errorMessage => _errorMessage;
  List<NoticiaModel> get noticias => _noticias;
  NoticiaModel? get noticiaDetalle => _noticiaDetalle;

  Future<void> cargarNoticias() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _noticias = await _service.obtenerNoticias();
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
    _noticiaDetalle = null;
    notifyListeners();

    try {
      _noticiaDetalle = await _service.obtenerDetalleNoticia(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  void limpiarDetalle() {
    _noticiaDetalle = null;
    notifyListeners();
  }

  void limpiar() {
    _noticias = [];
    _noticiaDetalle = null;
    _errorMessage = '';
    notifyListeners();
  }
}