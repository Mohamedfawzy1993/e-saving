class AppConstants {
  static const String appName = 'Money Saving Groups';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'money_saving.db';
  static const int databaseVersion = 1;
  
  // Storage Keys
  static const String currentUserKey = 'current_user_id';
  static const String biometricEnabledKey = 'biometric_enabled';
  
  // Validation
  static const int minPinLength = 4;
  static const int maxPinLength = 8;
  static const int minGroupNameLength = 3;
  static const int maxGroupNameLength = 50;
  static const int inviteCodeLength = 6;
  
  // UI
  static const double defaultPadding = 16.0;
  static const double cardBorderRadius = 12.0;
  static const double buttonBorderRadius = 8.0;
  
  // Date Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
}