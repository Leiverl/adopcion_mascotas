import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/pet.dart';

class FavoritesService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  // Obtener la lista de mascotas favoritas
  Future<List<Pet>> getFavorites() async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/favoritos/mis-favoritos');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Pet.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar los favoritos');
    }
  }

  // Añadir una mascota a favoritos
  Future<void> addFavorite(String petId) async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/favoritos');

    await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'mascotaId': petId}),
    );
  }

  // Eliminar una mascota de favoritos
  Future<void> removeFavorite(String petId) async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/favoritos/$petId');

    await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });
  }
}