import 'dart:convert';
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
    return UserProfile(
      nombre: json['nombre'] ?? 'Usuario',
      correo: json['correo'] ?? '',
      rol: json['rol'] ?? '',
    );
  }
}

class UserService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  Future<UserProfile> getMyProfile() async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('$_apiUrl/usuarios/mi-perfil');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      return UserProfile.fromJson(json.decode(response.body));
    } else {
      throw Exception('Error al cargar el perfil');
    }
  }
}
