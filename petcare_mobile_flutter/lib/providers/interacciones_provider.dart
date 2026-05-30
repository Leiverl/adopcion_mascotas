import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/interacciones_service.dart';
import 'package:petcare_mobile/models/evento.dart';

class InteraccionesProvider with ChangeNotifier {
  final InteraccionesService _service = InteraccionesService();
  List<Evento> _misEventos = []; // <-- Guardamos la lista de Eventos completa
  bool _isLoading = false;

  List<Evento> get misEventos => _misEventos;
  bool get isLoading => _isLoading;

  InteraccionesProvider() {
    fetchMisEventos();
  }

  Future<void> fetchMisEventos() async {
    _isLoading = true;
    notifyListeners();
    try {
      _misEventos = await _service.getMisEventos();
    } catch (e) {
      print(e);
      _misEventos = []; // En caso de error, la lista estará vacía
    }
    _isLoading = false;
    notifyListeners();
  }

  bool isInteresado(String eventoId) {
    return _misEventos.any((evento) => evento.id == eventoId);
  }

  // Ahora el método recibe el objeto Evento completo
  Future<void> toggleInteres(Evento evento) async {
    final isCurrentlyInterested = isInteresado(evento.id);
    
    // Actualizamos la UI inmediatamente para una respuesta rápida
    if (isCurrentlyInterested) {
      _misEventos.removeWhere((e) => e.id == evento.id);
    } else {
      _misEventos.add(evento);
    }
    notifyListeners();

    try {
      // Llamamos a la API en segundo plano
      await _service.toggleInteres(evento.id);
    } catch (e) {
      // Si la API falla, revertimos el cambio en la UI
      if (isCurrentlyInterested) {
        _misEventos.add(evento);
      } else {
        _misEventos.removeWhere((e) => e.id == evento.id);
      }
      notifyListeners();
    }
  }
}