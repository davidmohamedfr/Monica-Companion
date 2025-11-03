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

  /// Validate URL format (HTTPS-only for security)
  ///
  /// This method enforces HTTPS-only URLs to prevent man-in-the-middle attacks
  /// and ensure secure communication with external services.
  ///
  /// For development environments where HTTP may be needed, use
  /// [isValidUrlAllowHttp] instead.
  ///
  /// @param url The URL string to validate
  /// @return true if URL is valid and uses HTTPS scheme
  static bool isValidUrl(String url) {
    try {
      final Uri uri = Uri.parse(url);
      return uri.hasScheme && uri.scheme == 'https';
    } on FormatException {
      return false;
    }
  }

  /// Validate URL format allowing both HTTP and HTTPS
  ///
  /// This method allows both HTTP and HTTPS URLs, primarily for development
  /// and testing environments. **Should not be used in production** for
  /// external API endpoints.
  ///
  /// Use [isValidUrl] for production validation that enforces HTTPS.
  ///
  /// @param url The URL string to validate
  /// @return true if URL is valid and uses HTTP or HTTPS scheme
  static bool isValidUrlAllowHttp(String url) {
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

  /// Validate API token format with comprehensive security checks
  ///
  /// This method performs multiple validation checks to ensure API tokens
  /// meet security requirements:
  /// - Length validation (32-128 characters)
  /// - Format validation (alphanumeric with allowed special chars)
  /// - Entropy check (minimum 10 unique characters)
  ///
  /// Security rationale:
  /// - Minimum length ensures sufficient entropy
  /// - Maximum length prevents buffer overflow attempts
  /// - Character set restriction prevents injection attacks
  /// - Uniqueness check ensures token isn't trivially guessable
  ///
  /// @param token The API token string to validate
  /// @return true if token meets all security requirements
  static bool isValidApiToken(String token) {
    // Trim whitespace
    final String trimmedToken = token.trim();

    // Length validation: 32-128 characters
    if (trimmedToken.length < 32 || trimmedToken.length > 128) {
      return false;
    }

    // Format validation: alphanumeric plus dash, underscore, dot
    final RegExp tokenRegex = RegExp(r'^[A-Za-z0-9\-_\.]+$');
    if (!tokenRegex.hasMatch(trimmedToken)) {
      return false;
    }

    // Entropy check: at least 10 unique characters
    final Set<String> uniqueChars = trimmedToken.split('').toSet();
    if (uniqueChars.length < 10) {
      return false;
    }

    return true;
  }
}
