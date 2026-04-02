import 'dart:io';
import 'package:flutter/material.dart';
import '../models/mantenimiento_model.dart';
import '../services/mantenimiento_service.dart';

class MantenimientoProvider extends ChangeNotifier {
  final MantenimientoService _mantenimientoService = MantenimientoService();

  bool _isLoading = false;
  bool _isCreating = false;
  String _errorMessage = '';
  List<MantenimientoModel> _mantenimientos = [];

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String get errorMessage => _errorMessage;
  List<MantenimientoModel> get mantenimientos => _mantenimientos;

  Future<void> cargarMantenimientos({
    required int vehiculoId,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _mantenimientos = await _mantenimientoService.obtenerMantenimientos(
        vehiculoId: vehiculoId,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearMantenimiento({
    required int vehiculoId,
    required String tipo,
    required String descripcion,
    required String costo,
    List<File>? fotos,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _mantenimientoService.crearMantenimiento(
        vehiculoId: vehiculoId,
        tipo: tipo,
        descripcion: descripcion,
        costo: costo,
        fotos: fotos,
      );

      if (response['success'] == true) {
        await cargarMantenimientos(vehiculoId: vehiculoId);
        _isCreating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          response['message']?.toString() ??
          'No se pudo crear el mantenimiento';
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
    _mantenimientos = [];
    _errorMessage = '';
    notifyListeners();
  }
}