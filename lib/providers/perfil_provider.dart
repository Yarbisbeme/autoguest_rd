import 'dart:io';
import 'package:flutter/material.dart';
import '../models/perfil_model.dart';
import '../services/perfil_service.dart';

class PerfilProvider extends ChangeNotifier {
  final PerfilService _perfilService = PerfilService();

  bool _isLoading = false;
  bool _isUpdatingPhoto = false;
  String _errorMessage = '';
  PerfilModel? _perfil;

  bool get isLoading => _isLoading;
  bool get isUpdatingPhoto => _isUpdatingPhoto;
  String get errorMessage => _errorMessage;
  PerfilModel? get perfil => _perfil;

  Future<void> cargarPerfil() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _perfil = await _perfilService.obtenerPerfil();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cambiarFotoPerfil({
    required File foto,
  }) async {
    _isUpdatingPhoto = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _perfilService.cambiarFotoPerfil(
        foto: foto,
      );

      if (response['success'] == true) {
        await cargarPerfil();
        _isUpdatingPhoto = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          response['message']?.toString() ?? 'No se pudo cambiar la foto';
      _isUpdatingPhoto = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isUpdatingPhoto = false;
      notifyListeners();
      return false;
    }
  }

  void limpiar() {
    _perfil = null;
    _errorMessage = '';
    notifyListeners();
  }
}