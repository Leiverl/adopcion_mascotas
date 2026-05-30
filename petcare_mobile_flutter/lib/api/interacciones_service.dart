import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/evento.dart';

class InteraccionesService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  // Marcar/Desmarcar interés en un evento
  Future<void> toggleInteres(String eventoId) async {
    final token = await _storage.read(key: 'accessToken');
    // Asumimos que el endpoint es POST /interacciones-eventos
    final url = Uri.parse('$_apiUrl/interacciones-eventos');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'eventoId': eventoId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al actualizar el interés en el evento');
    }
  }

  // Obtener los eventos que le interesan al usuario
  Future<List<Evento>> getMisEventos() async {
     final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/interacciones-eventos/mis-eventos');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });
     if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // Asumimos que la API devuelve una lista de interacciones que contienen el objeto del evento
      return data.map((item) => Evento.fromJson(item['evento'])).toList();
    } else {
      throw Exception('Error al cargar mis eventos');
    }
  }
}