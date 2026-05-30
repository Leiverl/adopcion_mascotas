import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // <-- IMPORTAR
import 'package:petcare_mobile/api/auth_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  AuthStatus _status = AuthStatus.uninitialized;
  String? _token;

  AuthStatus get status => _status;
  
  // --- NUEVO GETTER PARA OBTENER EL USER ID ---
  String? get userId {
    if (_token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(_token!);
      return decodedToken['id']; // Asumimos que el payload del token tiene el campo 'id'
    }
    return null;
  }

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _token = await _authService.getToken();
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String correo, String contrasena) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      await _authService.login(correo, contrasena);
      await _tryAutoLogin(); // Reutilizamos para cargar el token
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      print(e);
      return false;
    }
  }

  Future<bool> register({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      await _authService.register(
        nombre: nombre, correo: correo, contrasena: contrasena,
      );
      return await login(correo, contrasena);
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      print(e);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}