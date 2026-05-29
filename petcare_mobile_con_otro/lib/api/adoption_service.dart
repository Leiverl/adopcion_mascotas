import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/adoption_request.dart';

class AdoptionService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  Future<void> createAdopcionRequest({
    required String petId,
    // --- CORRECCIÓN AQUÍ: Aceptamos un Mapa ---
    required Map<String, String> formResponses,
  }) async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/solicitudes-adopcion');

    final body = {
      'mascota': petId,
      'respuestasFormulario': formResponses,
    };

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(body),
    );

    if (response.statusCode != 201) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al crear la solicitud');
    }
  }

  Future<List<AdoptionRequest>> getMyAdoptionRequests() async {
    // ... (este método no cambia)
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/solicitudes-adopcion/mis-solicitudes');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => AdoptionRequest.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar tus solicitudes de adopción');
    }
  }
}