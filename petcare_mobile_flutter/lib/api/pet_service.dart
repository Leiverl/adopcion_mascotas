import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/pet.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PetService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  // --- MÉTODO ACTUALIZADO ---
  Future<List<Pet>> getPets({Map<String, String>? filters}) async {
    if (_apiUrl == null) {
      throw Exception('API_URL no está definida');
    }

    final token = await _storage.read(key: 'accessToken');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };

    // Construye la URL con los filtros opcionales
    final url = Uri.parse('$_apiUrl/mascotas').replace(queryParameters: filters);
    
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> petJson = json.decode(response.body);
      return petJson.map((json) => Pet.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar las mascotas');
    }
  }
}