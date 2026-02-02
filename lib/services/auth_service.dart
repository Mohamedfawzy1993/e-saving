import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import '../core/constants/app_constants.dart';
import '../core/utils/crypto_utils.dart';
import '../data/repositories/user_repository.dart';
import '../data/models/user.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  final UserRepository _userRepository = UserRepository();
  final LocalAuthentication _localAuth = LocalAuthentication();

  // Register new user
  Future<AuthResult> registerUser({
    required String username,
    required String fullName,
    required String pin,
    String? email,
  }) async {
    try {
      // Validate input
      if (!CryptoUtils.validatePin(pin)) {
        return AuthResult.error('PIN must be 4-8 digits');
      }

      if (!CryptoUtils.validateGroupName(fullName)) {
        return AuthResult.error('Full name must be 3-50 characters');
      }

      // Check if username already exists
      if (await _userRepository.usernameExists(username)) {
        return AuthResult.error('Username already exists');
      }

      // Check if email already exists
      if (email != null && email.isNotEmpty && await _userRepository.emailExists(email)) {
        return AuthResult.error('Email already exists');
      }

      final user = User(
        username: username,
        fullName: fullName,
        email: email?.isEmpty == true ? null : email,
        pinHash: CryptoUtils.hashPin(pin),
      );

      await _userRepository.createUser(user);
      await _storage.write(key: AppConstants.currentUserKey, value: user.id);
      
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Registration failed: ${e.toString()}');
    }
  }

  // Login user with PIN
  Future<AuthResult> loginWithPin(String username, String pin) async {
    try {
      if (!CryptoUtils.validatePin(pin)) {
        return AuthResult.error('Invalid PIN format');
      }

      final user = await _userRepository.getUserByUsername(username);
      if (user == null) {
        return AuthResult.error('User not found');
      }

      final hashedPin = CryptoUtils.hashPin(pin);
      if (user.pinHash != hashedPin) {
        return AuthResult.error('Incorrect PIN');
      }

      await _storage.write(key: AppConstants.currentUserKey, value: user.id);
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Login failed: ${e.toString()}');
    }
  }

  // Login with biometric
  Future<AuthResult> loginWithBiometric(String username) async {
    try {
      // Check if biometric is available
      final isAvailable = await _localAuth.canCheckBiometrics;
      if (!isAvailable) {
        return AuthResult.error('Biometric authentication not available');
      }

      // Authenticate with biometric
      final isAuthenticated = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access your account',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!isAuthenticated) {
        return AuthResult.error('Biometric authentication failed');
      }

      final user = await _userRepository.getUserByUsername(username);
      if (user == null) {
        return AuthResult.error('User not found');
      }

      await _storage.write(key: AppConstants.currentUserKey, value: user.id);
      return AuthResult.success(user);
    } catch (e) {
      return AuthResult.error('Biometric login failed: ${e.toString()}');
    }
  }

  // Get current logged-in user
  Future<User?> getCurrentUser() async {
    try {
      final userId = await _storage.read(key: AppConstants.currentUserKey);
      if (userId == null) return null;

      return await _userRepository.getUserById(userId);
    } catch (e) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Logout user
  Future<void> logout() async {
    await _storage.delete(key: AppConstants.currentUserKey);
  }

  // Update user PIN
  Future<AuthResult> updatePin(String userId, String oldPin, String newPin) async {
    try {
      if (!CryptoUtils.validatePin(newPin)) {
        return AuthResult.error('New PIN must be 4-8 digits');
      }

      final user = await _userRepository.getUserById(userId);
      if (user == null) {
        return AuthResult.error('User not found');
      }

      final oldHashedPin = CryptoUtils.hashPin(oldPin);
      if (user.pinHash != oldHashedPin) {
        return AuthResult.error('Current PIN is incorrect');
      }

      final updatedUser = user.copyWith(pinHash: CryptoUtils.hashPin(newPin));
      await _userRepository.updateUser(updatedUser);

      return AuthResult.success(updatedUser);
    } catch (e) {
      return AuthResult.error('PIN update failed: ${e.toString()}');
    }
  }

  // Check if biometric is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Enable/disable biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storage.write(
      key: AppConstants.biometricEnabledKey, 
      value: enabled.toString(),
    );
  }

  // Check if biometric is enabled
  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: AppConstants.biometricEnabledKey);
    return value == 'true';
  }
}

class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? error;

  AuthResult._({required this.isSuccess, this.user, this.error});

  factory AuthResult.success(User user) {
    return AuthResult._(isSuccess: true, user: user);
  }

  factory AuthResult.error(String error) {
    return AuthResult._(isSuccess: false, error: error);
  }
}