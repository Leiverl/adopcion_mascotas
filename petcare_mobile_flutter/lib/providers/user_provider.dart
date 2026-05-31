import 'package:flutter/material.dart';
import 'package:petcare_mobile/api/user_service.dart';

class UserProvider with ChangeNotifier {
  final UserService _userService = UserService();
  UserProfile? _profile;
  bool _isLoading = false;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;

  Future<void> fetchProfile() async {
    if (_profile != null) return; // ya cargado, no repetir
    _isLoading = true;
    notifyListeners();
    try {
      _profile = await _userService.getMyProfile();
    } catch (e) {
      debugPrint('UserProvider error: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    notifyListeners();
  }
}
