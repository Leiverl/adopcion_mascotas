import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/chat_service.dart';
import 'package:petcare_mobile/models/mensaje.dart';

class ChatProvider with ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<Mensaje> _mensajes = [];
  bool _isLoading = false;

  List<Mensaje> get mensajes => _mensajes;
  bool get isLoading => _isLoading;

  // Conecta al socket y carga el historial de mensajes
  Future<void> connectAndLoadHistory(
    String userId,
    String conversacionId,
    String solicitudId,
  ) async {
    _isLoading = true;
    notifyListeners();

    // Carga el historial vía REST
    _mensajes = await _chatService.getHistorial(conversacionId);
    
    // Conecta al WebSocket
    await _chatService.connect(userId);
    
    // Empieza a escuchar por nuevos mensajes
    _chatService.listenForMessages((nuevoMensaje) {
      _mensajes.add(nuevoMensaje);
      notifyListeners();
    });

    _isLoading = false;
    notifyListeners();
  }

  // Envía un nuevo mensaje
  void sendMessage(String texto, String solicitudId) {
    _chatService.sendMessage(texto, solicitudId);
  }

  // Desconecta del socket cuando la pantalla de chat se cierra
  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }
}