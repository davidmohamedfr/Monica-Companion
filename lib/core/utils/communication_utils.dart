import 'package:url_launcher/url_launcher.dart';

/// Utility class for communication actions (calls, SMS, email)
class CommunicationUtils {
  /// Private constructor to prevent instantiation
  CommunicationUtils._();

  /// Initiates a phone call to the specified phone number
  ///
  /// Opens the native phone dialer with the number pre-filled.
  /// Returns true if the phone app was successfully opened, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// await CommunicationUtils.makePhoneCall('+1234567890');
  /// ```
  static Future<bool> makePhoneCall(String phoneNumber) async {
    final String cleanNumber = _cleanPhoneNumber(phoneNumber);
    if (cleanNumber.isEmpty) {
      return false;
    }

    final Uri phoneUri = Uri(scheme: 'tel', path: cleanNumber);
    return _launchUrl(phoneUri);
  }

  /// Opens the native SMS app with the specified phone number
  ///
  /// Opens the messaging app with the number pre-filled.
  /// Returns true if the SMS app was successfully opened, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// await CommunicationUtils.sendSMS('+1234567890');
  /// ```
  static Future<bool> sendSMS(String phoneNumber) async {
    final String cleanNumber = _cleanPhoneNumber(phoneNumber);
    if (cleanNumber.isEmpty) {
      return false;
    }

    final Uri smsUri = Uri(scheme: 'sms', path: cleanNumber);
    return _launchUrl(smsUri);
  }

  /// Opens the default email client with the specified email address
  ///
  /// Opens the email app with the recipient pre-filled.
  /// Returns true if the email app was successfully opened, false otherwise.
  ///
  /// Example:
  /// ```dart
  /// await CommunicationUtils.sendEmail('user@example.com');
  /// ```
  static Future<bool> sendEmail(String email) async {
    final String cleanEmail = email.trim();
    if (cleanEmail.isEmpty) {
      return false;
    }

    final Uri emailUri = Uri(scheme: 'mailto', path: cleanEmail);
    return _launchUrl(emailUri);
  }

  /// Internal helper to launch URLs with proper error handling
  static Future<bool> _launchUrl(Uri uri) async {
    try {
      final bool canLaunch = await canLaunchUrl(uri);
      if (!canLaunch) {
        return false;
      }

      return await launchUrl(uri);
    } on Object {
      return false;
    }
  }

  /// Cleans and normalizes phone numbers
  ///
  /// Removes whitespace and validates the number has content
  static String _cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.trim();
  }
}
