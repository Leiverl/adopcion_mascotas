import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

/// Maneja el ciclo de vida del token FCM:
/// - Solicita permisos al usuario
/// - Obtiene el token del dispositivo
/// - Lo envía al backend (POST /usuarios/fcm-token)
/// - Lo refresca automáticamente cuando Firebase lo rota
/// - Lo elimina al cerrar sesión (DELETE /usuarios/fcm-token)
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get _baseUrl => dotenv.env['API_URL'] ?? '';

  // ── INICIALIZAR ───────────────────────────────────────────────────────
  Future<void> initialize() async {
    // 1. Pedir permisos (Android 13+ y iOS los requieren)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      return; // El usuario negó permisos, no hacemos nada
    }

    // 2. Obtener token actual y enviarlo al backend
    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenLocally(token);
      await _sendTokenToBackend(token);
    }

    // 3. Escuchar cuando Firebase rota el token automáticamente
    _messaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenLocally(newToken);
      await _sendTokenToBackend(newToken);
    });

    // 4. Manejar notificaciones recibidas con la app en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Las notificaciones en foreground no se muestran automáticamente
      // Se puede mostrar un snackbar, banner, etc. aquí si se desea
    });
  }

  // ── GUARDAR TOKEN LOCALMENTE ──────────────────────────────────────
  Future<void> _saveTokenLocally(String token) async {
    await _storage.write(key: 'fcm_token', value: token);
  }

  // ── ENVIAR TOKEN AL BACKEND ──────────────────────────────────────
  Future<void> _sendTokenToBackend(String token) async {
    try {
      final jwt = await _storage.read(key: 'auth_token');
      if (jwt == null) return; // usuario no logueado aún

      await http.post(
        Uri.parse('$_baseUrl/usuarios/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {
      // Fallo silencioso — se reintentará al próximo inicio de sesión
    }
  }

  // ── LLAMAR AL CERRAR SESIÓN ──────────────────────────────────────
  Future<void> removeTokenOnLogout() async {
    try {
      final token = await _storage.read(key: 'fcm_token');
      final jwt = await _storage.read(key: 'auth_token');
      if (token == null || jwt == null) return;

      await http.delete(
        Uri.parse('$_baseUrl/usuarios/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': token}),
      );

      await _storage.delete(key: 'fcm_token');
    } catch (_) {
      // Fallo silencioso
    }
  }
}
