import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/notificacion.dart';

class NotificacionesService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  Future<String?> _getToken() async {
    return await _storage.read(key: 'accessToken');
  }

  // GET /mis-notificaciones
  Future<List<Notificacion>> getMisNotificaciones() async {
    final token = await _getToken();
    final url = Uri.parse('$_apiUrl/notificaciones/mis-notificaciones');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Notificacion.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las notificaciones');
    }
  }

  // PATCH /:id/leida
  Future<void> markAsRead(String notificationId) async {
    final token = await _getToken();
    final url = Uri.parse('$_apiUrl/notificaciones/$notificationId/leida');

    await http.patch(url, headers: {
      'Authorization': 'Bearer $token',
    });
    // No nos preocupamos por la respuesta si es exitosa
  }

  // POST /marcar-todas-leidas
  Future<void> markAllAsRead() async {
    final token = await _getToken();
    final url = Uri.parse('$_apiUrl/notificaciones/marcar-todas-leidas');

    await http.post(url, headers: {
      'Authorization': 'Bearer $token',
    });
  }
}