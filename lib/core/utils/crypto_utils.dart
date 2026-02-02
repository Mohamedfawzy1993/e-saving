import 'dart:convert';
import 'package:crypto/crypto.dart';

class CryptoUtils {
  static String hashPin(String pin) {
    final bytes = utf8.encode(pin);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = DateTime.now().millisecondsSinceEpoch;
    return List.generate(6, (index) => 
      chars[(random + index) % chars.length]
    ).join();
  }

  static bool validatePin(String pin) {
    return pin.length >= 4 && 
           pin.length <= 8 && 
           RegExp(r'^\d+$').hasMatch(pin);
  }

  static bool validateAmount(String amount) {
    final parsed = double.tryParse(amount);
    return parsed != null && parsed > 0;
  }

  static bool validateGroupName(String name) {
    return name.trim().length >= 3 && name.trim().length <= 50;
  }
}