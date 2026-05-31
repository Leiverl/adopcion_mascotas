import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/favorites_service.dart';
import 'package:petcare_mobile/models/pet.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  List<Pet> _favoritePets = [];
  bool _isLoading = false;

  List<Pet> get favoritePets => _favoritePets;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _favoritePets = await _favoritesService.getFavorites();
    } catch (e) {
      debugPrint('FavoritesProvider error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Retorna el mensaje a mostrar en el toast
  Future<String> toggleFavorite(Pet pet) async {
    final isFav = isFavorite(pet.id);
    // Optimistic update
    if (isFav) {
      _favoritePets.removeWhere((p) => p.id == pet.id);
    } else {
      _favoritePets.add(pet);
    }
    notifyListeners();

    try {
      if (isFav) {
        await _favoritesService.removeFavorite(pet.id);
        return '¡Eliminado de favoritos!';
      } else {
        await _favoritesService.addFavorite(pet.id);
        return '¡Agregado a favoritos!';
      }
    } catch (e) {
      // Revertir si falla
      if (isFav) {
        _favoritePets.add(pet);
      } else {
        _favoritePets.removeWhere((p) => p.id == pet.id);
      }
      notifyListeners();
      debugPrint('FavoritesProvider toggleFavorite error: $e');
      return 'Error al actualizar favoritos';
    }
  }

  bool isFavorite(String petId) {
    return _favoritePets.any((p) => p.id == petId);
  }

  /// Limpia los favoritos al cerrar sesión
  void clear() {
    _favoritePets = [];
    _isLoading = false;
    notifyListeners();
  }
}
