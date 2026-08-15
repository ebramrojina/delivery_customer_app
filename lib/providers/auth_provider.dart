import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';
import '../services/api_exception.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();

  AuthStatus status = AuthStatus.unknown;
  AppUser? currentUser;
  String? token;
  bool isLoading = false;
  String? errorMessage;

  /// Call once at app startup to restore a saved session.
  Future<void> tryAutoLogin() async {
    final savedToken = await _storageService.getToken();
    final savedUser = await _storageService.getUser();

    if (savedToken != null && savedUser != null) {
      token = savedToken;
      currentUser = savedUser;
      status = AuthStatus.authenticated;
    } else {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String phone, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(phone: phone, password: password);
      token = result.token;
      currentUser = result.user;
      status = AuthStatus.authenticated;
      await _storageService.saveSession(result.token, result.user);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String phone, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.register(name: name, phone: phone, password: password);
      token = result.token;
      currentUser = result.user;
      status = AuthStatus.authenticated;
      await _storageService.saveSession(result.token, result.user);
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storageService.clearSession();
    token = null;
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
