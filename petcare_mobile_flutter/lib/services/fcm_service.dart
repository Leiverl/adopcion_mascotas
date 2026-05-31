import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  String get _baseUrl => dotenv.env['API_URL'] ?? '';

  Future<void> initialize() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    final token = await _messaging.getToken();
    if (token != null) {
      await _saveTokenLocally(token);
      await _sendTokenToBackend(token);
    }

    _messaging.onTokenRefresh.listen((newToken) async {
      await _saveTokenLocally(newToken);
      await _sendTokenToBackend(newToken);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // Foreground: mostrar banner/snackbar si se desea
    });
  }

  Future<void> _saveTokenLocally(String token) async {
    await _storage.write(key: 'fcm_token', value: token);
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final jwt = await _storage.read(key: 'accessToken'); // ← corregido
      if (jwt == null) return;

      await http.post(
        Uri.parse('$_baseUrl/usuarios/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({'token': token}),
      );
    } catch (_) {}
  }

  Future<void> removeTokenOnLogout() async {
    try {
      final token = await _storage.read(key: 'fcm_token');
      final jwt = await _storage.read(key: 'accessToken'); // ← corregido
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
    } catch (_) {}
  }
}
