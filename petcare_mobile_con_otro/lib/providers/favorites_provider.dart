import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/favorites_service.dart';
import 'package:petcare_mobile/models/pet.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoritesService _favoritesService = FavoritesService();
  List<Pet> _favoritePets = [];
  bool _isLoading = false;

  List<Pet> get favoritePets => _favoritePets;
  bool get isLoading => _isLoading;

  FavoritesProvider() {
    fetchFavorites();
  }

  Future<void> fetchFavorites() async {
    _isLoading = true;
    notifyListeners();
    try {
      _favoritePets = await _favoritesService.getFavorites();
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  bool isFavorite(String petId) {
    return _favoritePets.any((pet) => pet.id == petId);
  }

  // --- MÉTODO MODIFICADO ---
  Future<String> toggleFavorite(Pet pet) async {
    final isCurrentlyFavorite = isFavorite(pet.id);
    String message;

    if (isCurrentlyFavorite) {
      _favoritePets.removeWhere((p) => p.id == pet.id);
      await _favoritesService.removeFavorite(pet.id);
      message = 'Eliminado de favoritos';
    } else {
      _favoritePets.add(pet);
      await _favoritesService.addFavorite(pet.id);
      message = '¡Añadido a favoritos!';
    }
    
    notifyListeners();
    return message;
  }
}