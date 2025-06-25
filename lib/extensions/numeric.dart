class IntUtils {
  static int tryParseNull(Object? value) {
    if (value is int) return value;
    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) return parsed;
    }
    print("Failed to parse value: $value, returning 0");
    return 0;
  }
}
