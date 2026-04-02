import 'dart:math';
import 'package:flutter/material.dart';
import '../core/storage/token_storage.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  bool _isLoggedIn = false;
  String _token = '';
  String _errorMessage = '';
  String _generatedPassword = '';

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  String get token => _token;
  String get errorMessage => _errorMessage;
  String get generatedPassword => _generatedPassword;

  Future<void> checkLoginStatus() async {
    final savedToken = await TokenStorage.getToken();

    if (savedToken != null && savedToken.isNotEmpty) {
      _token = savedToken;
      _isLoggedIn = true;
    } else {
      _isLoggedIn = false;
    }

    notifyListeners();
  }

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  String _generateRandomPassword({int length = 10}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();

    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<bool> registroAutomatico({
    required String matricula,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    _generatedPassword = '';
    notifyListeners();

    try {
      final password = _generateRandomPassword(length: 10);

      final registroResult = await _authService.registro(
        matricula: matricula,
      );

      final registroOk = registroResult['success'] == true;
      final tokenTemporal = registroResult['data']?['token']?.toString() ?? '';

      if (!registroOk || tokenTemporal.isEmpty) {
        _errorMessage =
            registroResult['message']?.toString() ??
            'No se pudo registrar el usuario';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final activarResult = await _authService.activar(
        tokenTemporal: tokenTemporal,
        contrasena: password,
      );

      final activarOk = activarResult['success'] == true;
      final tokenDefinitivo =
          activarResult['data']?['token']?.toString() ?? '';

      if (!activarOk || tokenDefinitivo.isEmpty) {
        _errorMessage =
            activarResult['message']?.toString() ??
            'No se pudo activar la cuenta';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _generatedPassword = password;
      _token = tokenDefinitivo;
      _isLoggedIn = true;

      await TokenStorage.saveToken(tokenDefinitivo);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> activarManual({
    required String tokenTemporal,
    required String contrasena,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.activar(
        tokenTemporal: tokenTemporal,
        contrasena: contrasena,
      );

      final ok = result['success'] == true;
      final tokenDefinitivo = result['data']?['token']?.toString() ?? '';

      if (ok && tokenDefinitivo.isNotEmpty) {
        _token = tokenDefinitivo;
        _isLoggedIn = true;
        await TokenStorage.saveToken(tokenDefinitivo);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          result['message']?.toString() ?? 'No se pudo activar la cuenta';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String matricula,
    required String contrasena,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final result = await _authService.login(
        matricula: matricula,
        contrasena: contrasena,
      );

      final ok = result['success'] == true;
      final tokenRecibido = result['data']?['token']?.toString() ?? '';

      if (ok && tokenRecibido.isNotEmpty) {
        _token = tokenRecibido;
        _isLoggedIn = true;
        _generatedPassword = '';
        await TokenStorage.saveToken(tokenRecibido);

        _isLoading = false;
        notifyListeners();
        return true;
      }

      _errorMessage =
          result['message']?.toString() ?? 'No se pudo iniciar sesión';
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

Future<bool> olvidarContrasena({
  required String matricula,
}) async {
  _isLoading = true;
  _errorMessage = '';
  notifyListeners();

  try {
    final result = await _authService.olvidarContrasena(
      matricula: matricula,
    );

    final ok = result['success'] == true;
    final message =
        result['message']?.toString() ?? 'No se pudo procesar la solicitud';

    _errorMessage = message;
    _isLoading = false;
    notifyListeners();

    return ok;
  } catch (e) {
    _errorMessage = e.toString().replaceFirst('Exception: ', '');
    _isLoading = false;
    notifyListeners();
    return false;
  }
}
  Future<void> logout() async {
    await TokenStorage.removeToken();
    _token = '';
    _isLoggedIn = false;
    _generatedPassword = '';
    _errorMessage = '';
    notifyListeners();
  }
}