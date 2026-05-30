import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/notificaciones_service.dart';
import 'package:petcare_mobile/models/notificacion.dart';

class NotificacionesProvider with ChangeNotifier {
  final NotificacionesService _service = NotificacionesService();
  List<Notificacion> _notificaciones = [];
  bool _isLoading = false;

  List<Notificacion> get notificaciones => _notificaciones;
  bool get isLoading => _isLoading;
  int get unreadCount => _notificaciones.where((n) => !n.leida).length;

  NotificacionesProvider() {
    fetchNotificaciones();
  }

  Future<void> fetchNotificaciones() async {
    _isLoading = true;
    notifyListeners();
    try {
      _notificaciones = await _service.getMisNotificaciones();
    } catch (e) {
      print(e);
      _notificaciones = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markAsRead(String notificationId) async {
    // Find the notification in the list
    final index = _notificaciones.indexWhere((n) => n.id == notificationId);
    if (index != -1 && !_notificaciones[index].leida) {
      // Optimistically update the UI
      _notificaciones[index] = Notificacion(
        id: _notificaciones[index].id,
        titulo: _notificaciones[index].titulo,
        cuerpo: _notificaciones[index].cuerpo,
        leida: true, // Mark as read
        ruta: _notificaciones[index].ruta,
        fechaCreacion: _notificaciones[index].fechaCreacion,
      );
      notifyListeners();
      // Call the API in the background
      await _service.markAsRead(notificationId);
    }
  }

  Future<void> markAllAsRead() async {
    // Optimistically update the UI
    _notificaciones = _notificaciones.map((n) {
      return Notificacion(
        id: n.id,
        titulo: n.titulo,
        cuerpo: n.cuerpo,
        leida: true,
        ruta: n.ruta,
        fechaCreacion: n.fechaCreacion,
      );
    }).toList();
    notifyListeners();
    // Call the API in the background
    await _service.markAllAsRead();
  }
}