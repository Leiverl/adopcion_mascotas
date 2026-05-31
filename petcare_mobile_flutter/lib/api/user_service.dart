import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class UserProfile {
  final String nombre;
  final String correo;
  final String rol;

  UserProfile({
    required this.nombre,
    required this.correo,
    required this.rol,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    debugPrint('UserProfile.fromJson: $json');
    return UserProfile(
      nombre: (json['nombre'] ?? '').toString(),
      correo: (json['correo'] ?? '').toString(),
      rol: (json['rol'] ?? '').toString(),
    );
  }
}

class UserService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  Future<UserProfile> getMyProfile() async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/usuarios/mi-perfil');

    debugPrint('UserService GET $url');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    debugPrint('UserService status: ${response.statusCode}');
    debugPrint('UserService body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      // El endpoint puede devolver el objeto directamente o anidado
      if (data is Map<String, dynamic>) {
        return UserProfile.fromJson(data);
      }
      throw Exception('Formato de respuesta inesperado');
    } else {
      throw Exception('Error ${response.statusCode}: ${response.body}');
    }
  }
}
