/// Common validation utilities
class Validators {
  Validators._();

  /// Validate email format
  static bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate URL format
  static bool isValidUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } on FormatException {
      return false;
    }
  }

  /// Validate phone number format (basic)
  static bool isValidPhoneNumber(String phoneNumber) {
    final RegExp phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phoneRegex.hasMatch(phoneNumber);
  }

  /// Check if string is not null and not empty
  static bool isNotEmpty(String? value) =>
      value != null && value.trim().isNotEmpty;

  /// Validate API token format (basic check for non-empty string)
  static bool isValidApiToken(String token) =>
      token.trim().isNotEmpty && token.length >= 10;
}
