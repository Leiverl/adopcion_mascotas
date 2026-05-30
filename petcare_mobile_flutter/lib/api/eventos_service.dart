import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/evento.dart';

class EventosService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  // Obtener la lista de todos los eventos
  Future<List<Evento>> getEventos() async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/eventos');

    // Tu endpoint findAll() requiere autenticación, así que enviamos el token
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los eventos');
    }
  }
}