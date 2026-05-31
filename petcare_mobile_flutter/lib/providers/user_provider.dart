import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserProfile? _profile;
  bool _isLoading = false;
  String? _error;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Siempre recarga desde la API (no cachea para evitar datos vacíos)
  Future<void> fetchProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _profile = await _userService.getMyProfile();
    } catch (e) {
      _error = e.toString();
      debugPrint('UserProvider error: $_error');
    }
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
