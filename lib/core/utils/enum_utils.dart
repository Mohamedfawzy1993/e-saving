class EnumUtils {
  static String getEnumName(dynamic enumValue) {
    return enumValue.toString().split('.').last;
  }
  
  static T getEnumFromString<T>(List<T> enumValues, String value) {
    return enumValues.firstWhere(
      (e) => e.toString().split('.').last == value,
    );
  }
}