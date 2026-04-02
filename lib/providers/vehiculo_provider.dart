import 'dart:io';
import 'package:flutter/material.dart';
import '../models/vehiculo_model.dart';
import '../services/vehiculo_service.dart';

class VehiculoProvider extends ChangeNotifier {
  final VehiculoService _vehiculoService = VehiculoService();

  bool _isLoading = false;
  bool _isCreating = false;
  bool _isDetailLoading = false;
  bool _isUpdating = false;
  String _errorMessage = '';
  List<VehiculoModel> _vehiculos = [];
  Map<String, dynamic>? _vehiculoDetalle;

  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  bool get isDetailLoading => _isDetailLoading;
  bool get isUpdating => _isUpdating;
  String get errorMessage => _errorMessage;
  List<VehiculoModel> get vehiculos => _vehiculos;
  Map<String, dynamic>? get vehiculoDetalle => _vehiculoDetalle;

  Future<void> cargarVehiculos({String? marca, int page = 1}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      _vehiculos = await _vehiculoService.obtenerVehiculos(
        marca: marca,
        page: page,
      );
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> crearVehiculo({
    required String placa,
    required String chasis,
    required String marca,
    required String modelo,
    required String anio,
    required String cantidadRuedas,
    File? foto,
  }) async {
    _isCreating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _vehiculoService.crearVehiculo(
        placa: placa,
        chasis: chasis,
        marca: marca,
        modelo: modelo,
        anio: anio,
        cantidadRuedas: cantidadRuedas,
        foto: foto,
      );

      if (response['success'] == true) {
        await cargarVehiculos();
        _isCreating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          response['message']?.toString() ?? 'No se pudo crear el vehículo';
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

  Future<void> cargarVehiculoDetalle(int id) async {
    _isDetailLoading = true;
    _errorMessage = '';
    _vehiculoDetalle = null;
    notifyListeners();

    try {
      _vehiculoDetalle = await _vehiculoService.obtenerVehiculoDetalle(id);
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isDetailLoading = false;
      notifyListeners();
    }
  }

  Future<bool> editarVehiculo({
    required int id,
    required String placa,
    required String chasis,
    required String marca,
    required String modelo,
    required String anio,
    required String cantidadRuedas,
  }) async {
    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _vehiculoService.editarVehiculo(
        id: id,
        placa: placa,
        chasis: chasis,
        marca: marca,
        modelo: modelo,
        anio: anio,
        cantidadRuedas: cantidadRuedas,
      );

      if (response['success'] == true) {
        await cargarVehiculos();
        await cargarVehiculoDetalle(id);
        _isUpdating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          response['message']?.toString() ?? 'No se pudo editar el vehículo';
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

  Future<bool> cambiarFotoVehiculo({
    required int vehiculoId,
    required File foto,
  }) async {
    _isUpdating = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final response = await _vehiculoService.cambiarFotoVehiculo(
        vehiculoId: vehiculoId,
        foto: foto,
      );

      if (response['success'] == true) {
        await cargarVehiculos();
        await cargarVehiculoDetalle(vehiculoId);
        _isUpdating = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          response['message']?.toString() ?? 'No se pudo cambiar la foto';
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

  void limpiarDetalle() {
    _vehiculoDetalle = null;
    notifyListeners();
  }

  void limpiar() {
    _vehiculos = [];
    _vehiculoDetalle = null;
    _errorMessage = '';
    notifyListeners();
  }
}