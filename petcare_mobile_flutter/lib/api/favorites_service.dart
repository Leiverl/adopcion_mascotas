import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/pet.dart';

class FavoritesService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  Future<List<Pet>> getFavorites() async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/favoritos/mis-favoritos');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      // La API devuelve objetos Favorito: { _id, usuario, mascota: { ... } }
      // Hay que extraer el campo 'mascota' de cada elemento
      return data
          .where((item) => item['mascota'] != null)
          .map((item) => Pet.fromJson(item['mascota']))
          .toList();
    } else {
      throw Exception('Error al cargar los favoritos');
    }
  }

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

  Future<void> removeFavorite(String petId) async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/favoritos/$petId');

    await http.delete(url, headers: {
      'Authorization': 'Bearer $token',
    });
  }
}
