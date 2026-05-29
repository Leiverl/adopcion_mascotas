import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String? _apiUrl = dotenv.env['API_URL'];
  final _storage = const FlutterSecureStorage();

  // Iniciar Sesión
  Future<String> login(String correo, String contrasena) async {
    if (_apiUrl == null) {
      throw Exception('API_URL no está definida en el archivo .env');
    }
    final url = Uri.parse('$_apiUrl/auth/login');
    
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    if (response.statusCode == 201) {
      final responseData = json.decode(response.body);
      final String token = responseData['accessToken'];
      
      await _storage.write(key: 'accessToken', value: token);
      
      return 'Login exitoso';
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error al iniciar sesión');
    }
  }

  // Registrar un nuevo usuario
  Future<String> register({
    required String nombre,
    required String correo,
    required String contrasena,
  }) async {
    if (_apiUrl == null) {
      throw Exception('API_URL no está definida en el archivo .env');
    }
    // --- CORRECCIÓN AQUÍ ---
    final url = Uri.parse('$_apiUrl/usuarios/registro');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombre,
        'correo': correo,
        'contrasena': contrasena,
        // El backend asignará el rol de 'ADOPTANTE' por defecto en esta ruta
      }),
    );

    if (response.statusCode == 201) {
      return 'Registro exitoso';
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['message'] ?? 'Error en el registro');
    }
  }

  // Cerrar Sesión
  Future<void> logout() async {
    await _storage.delete(key: 'accessToken');
  }

  // Obtener el token (para verificar si hay sesión activa)
  Future<String?> getToken() async {
    return await _storage.read(key: 'accessToken');
  }
}