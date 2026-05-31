import 'package:flutter/material.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:petcare_mobile/api/auth_service.dart';
import 'package:petcare_mobile/services/fcm_service.dart';

enum AuthStatus { uninitialized, authenticated, unauthenticated, authenticating }

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FcmService _fcmService = FcmService();
  AuthStatus _status = AuthStatus.uninitialized;
  String? _token;

  AuthStatus get status => _status;

  Map<String, dynamic> get _decodedToken {
    if (_token != null) {
      try {
        return JwtDecoder.decode(_token!);
      } catch (_) {}
    }
    return {};
  }

  String? get userId => _decodedToken['id']?.toString();
  String? get userNombre => _decodedToken['nombre']?.toString();
  String? get userCorreo => _decodedToken['correo']?.toString();
  String? get userRol => _decodedToken['rol']?.toString();

  AuthProvider() {
    _tryAutoLogin();
  }

  Future<void> _tryAutoLogin() async {
    _token = await _authService.getToken();
    if (_token != null && !JwtDecoder.isExpired(_token!)) {
      _status = AuthStatus.authenticated;
      // Si ya hay sesión activa al abrir la app, inicializar FCM
      await _fcmService.initialize();
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
      await _tryAutoLogin();
      // Inicializar FCM tras login exitoso (pide permisos y envía token)
      await _fcmService.initialize();
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      debugPrint('AuthProvider login error: $e');
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
      debugPrint('AuthProvider register error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    // Eliminar FCM token del backend antes de borrar el JWT
    await _fcmService.removeTokenOnLogout();
    await _authService.logout();
    _token = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
