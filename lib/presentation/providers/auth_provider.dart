import 'package:flutter/foundation.dart';
import '../../data/models/user.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;

  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> checkAuthStatus() async {
    try {
      _currentUser = await _authService.getCurrentUser();
      _isLoggedIn = _currentUser != null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isLoggedIn = false;
    }
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String fullName,
    required String pin,
    String? email,
  }) async {
    _setLoading(true);
    try {
      final result = await _authService.registerUser(
        username: username,
        fullName: fullName,
        pin: pin,
        email: email,
      );

      if (result.isSuccess) {
        _currentUser = result.user;
        _isLoggedIn = true;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithPin(String username, String pin) async {
    _setLoading(true);
    try {
      final result = await _authService.loginWithPin(username, pin);

      if (result.isSuccess) {
        _currentUser = result.user;
        _isLoggedIn = true;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> loginWithBiometric(String username) async {
    _setLoading(true);
    try {
      final result = await _authService.loginWithBiometric(username);

      if (result.isSuccess) {
        _currentUser = result.user;
        _isLoggedIn = true;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updatePin(String oldPin, String newPin) async {
    if (_currentUser == null) return false;

    _setLoading(true);
    try {
      final result = await _authService.updatePin(_currentUser!.id, oldPin, newPin);

      if (result.isSuccess) {
        _currentUser = result.user;
        _error = null;
        _setLoading(false);
        return true;
      } else {
        _error = result.error;
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> isBiometricAvailable() async {
    return await _authService.isBiometricAvailable();
  }

  Future<bool> isBiometricEnabled() async {
    return await _authService.isBiometricEnabled();
  }

  Future<void> setBiometricEnabled(bool enabled) async {
    await _authService.setBiometricEnabled(enabled);
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}