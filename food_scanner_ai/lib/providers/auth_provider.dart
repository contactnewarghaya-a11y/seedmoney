import 'package:flutter/foundation.dart';
import '../api/auth_api.dart';
import '../services/storage_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthApi _authApi = AuthApi();
  bool _isLoading = false;
  String? _token;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;

  Future<void> checkAuthStatus() async {
    _token = await StorageService.getToken();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authApi.login(email, password);
      if (response['success'] == true) {
        _token = response['token'];
        await StorageService.saveToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Login error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _authApi.register(name, email, password);
      if (response['success'] == true) {
        _token = response['token'];
        await StorageService.saveToken(_token!);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint("Register error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  Future<void> logout() async {
    await StorageService.removeToken();
    _token = null;
    notifyListeners();
  }
}
