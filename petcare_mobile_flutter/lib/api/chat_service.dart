import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:petcare_mobile/models/mensaje.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  final String? _apiUrl = dotenv.env['API_URL']?.replaceAll('/api/v1', '');
  final _storage = const FlutterSecureStorage();
  IO.Socket? _socket;

  // Conectar al WebSocket
  Future<void> connect(String userId) async {
    final token = await _storage.read(key: 'accessToken');
    if (_apiUrl == null) throw Exception('API_URL no definida');

    _socket = IO.io(_apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'query': {'userId': userId, 'token': token} // Enviamos userId y token
    });

    _socket!.connect();

    _socket!.onConnect((_) => print('Conectado al WebSocket'));
    _socket!.onDisconnect((_) => print('Desconectado del WebSocket'));
  }

  // Desconectar
  void disconnect() {
    _socket?.disconnect();
  }

  // Enviar un mensaje
  void sendMessage(String texto, String solicitudId) {
    _socket?.emit('enviarMensaje', {
      'solicitudId': solicitudId,
      'texto': texto,
    });
  }

  // Escuchar nuevos mensajes
  void listenForMessages(Function(Mensaje) onMessageReceived) {
    _socket?.on('nuevoMensaje', (data) {
      onMessageReceived(Mensaje.fromJson(data));
    });
  }
  
  // Obtener historial de mensajes vía REST
  Future<List<Mensaje>> getHistorial(String conversacionId) async {
    final token = await _storage.read(key: 'accessToken');
    final url = Uri.parse('${dotenv.env['API_URL']}/conversaciones/$conversacionId/mensajes');

    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Mensaje.fromJson(json)).toList();
    } else {
      throw Exception('Error al cargar el historial del chat');
    }
  }
}