// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  User?  _user;
  bool   _loading = false;
  String _error   = '';

  User?  get user      => _user;
  bool   get loading   => _loading;
  String get error     => _error;
  bool   get isLoggedIn => _user != null;

  final _api = ApiService();

  Future<void> init() async {
    if (await _api.isLoggedIn()) {
      _user = await _api.getCachedUser();
      notifyListeners();
      final fresh = await _api.getMe();
      if (fresh != null) { _user = fresh; notifyListeners(); }
    }
  }

  Future<bool> login(String email, String password) async {
    _loading = true; _error = ''; notifyListeners();
    final res = await _api.login(email, password);
    _loading = false;
    if (res['success'] == true) {
      _user = await _api.getMe() ?? (res['user'] != null ? User.fromJson(res['user']) : null);
      notifyListeners();
      return true;
    }
    _error = res['message'] ?? 'Login failed';
    notifyListeners();
    return false;
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    _loading = true; _error = ''; notifyListeners();
    final res = await _api.register(name, email, phone, password);
    _loading = false;
    if (res['success'] == true) {
      _user = await _api.getMe();
      notifyListeners();
      return true;
    }
    _error = res['message'] ?? 'Registration failed';
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    await _api.logout();
    _user = null;
    notifyListeners();
  }

  void clearError() { _error = ''; notifyListeners(); }
}
