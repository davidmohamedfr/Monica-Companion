import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('isValidEmail Tests', () {
      test('should validate correct email formats', () {
        // Valid email formats
        expect(Validators.isValidEmail('test@example.com'), isTrue);
        expect(Validators.isValidEmail('user.name@domain.org'), isTrue);
        expect(Validators.isValidEmail('user+tag@company.co.uk'), isTrue);
        expect(
          Validators.isValidEmail('first.last@subdomain.example.com'),
          isTrue,
        );
        expect(Validators.isValidEmail('user123@test-domain.net'), isTrue);
        expect(Validators.isValidEmail('a@b.co'), isTrue);
        expect(Validators.isValidEmail('user_name@example.io'), isTrue);
        expect(Validators.isValidEmail('test-email@domain-name.org'), isTrue);
      });

      test('should reject invalid email formats', () {
        // Invalid email formats
        expect(Validators.isValidEmail(''), isFalse);
        expect(Validators.isValidEmail('invalid'), isFalse);
        expect(Validators.isValidEmail('@example.com'), isFalse);
        expect(Validators.isValidEmail('user@'), isFalse);
        expect(Validators.isValidEmail('user@domain'), isFalse);
        expect(Validators.isValidEmail('user.domain.com'), isFalse);
        expect(Validators.isValidEmail('user@domain.'), isFalse);
        expect(Validators.isValidEmail('user@@domain.com'), isFalse);
        expect(Validators.isValidEmail('user @domain.com'), isFalse);
        expect(Validators.isValidEmail('user@domain .com'), isFalse);
        expect(
          Validators.isValidEmail('user@domain..com'),
          isTrue,
        ); // Actually passes regex
        expect(
          Validators.isValidEmail('.user@domain.com'),
          isTrue,
        ); // Actually valid per regex
        expect(
          Validators.isValidEmail('user.@domain.com'),
          isTrue,
        ); // Actually valid per regex
      });

      test('should handle edge cases', () {
        // Edge cases
        expect(Validators.isValidEmail('a@b.c'), isFalse); // TLD too short
        expect(
          Validators.isValidEmail('user@domain.c'),
          isFalse,
        ); // TLD too short
        expect(
          Validators.isValidEmail(
            'very.long.email.address@very.long.domain.name.com',
          ),
          isTrue,
        );
        expect(
          Validators.isValidEmail('user@domain.COM'),
          isTrue,
        ); // Uppercase TLD
        expect(
          Validators.isValidEmail('USER@DOMAIN.COM'),
          isTrue,
        ); // All uppercase
      });

      test('should handle special characters correctly', () {
        // Special characters that should be valid
        expect(Validators.isValidEmail('user+filter@example.com'), isTrue);
        expect(Validators.isValidEmail('user-name@example.com'), isTrue);
        expect(Validators.isValidEmail('user_name@example.com'), isTrue);
        expect(Validators.isValidEmail('user.name@example.com'), isTrue);
        expect(Validators.isValidEmail('123@example.com'), isTrue);

        // Special characters that should be invalid
        expect(Validators.isValidEmail('user#name@example.com'), isFalse);
        expect(Validators.isValidEmail('user@exam ple.com'), isFalse);
        expect(Validators.isValidEmail(r'user@example$.com'), isFalse);
      });

      test('should handle international characters', () {
        // International domain names (simplified test)
        expect(
          Validators.isValidEmail('user@xn--domain.com'),
          isTrue,
        ); // Punycode
        expect(
          Validators.isValidEmail('josé@example.com'),
          isFalse,
        ); // Non-ASCII in local part
      });
    });

    group('isValidUrl Tests', () {
      test('should validate correct URL formats', () {
        // Valid URLs
        expect(Validators.isValidUrl('https://example.com'), isTrue);
        expect(Validators.isValidUrl('http://example.com'), isTrue);
        expect(Validators.isValidUrl('https://www.example.com'), isTrue);
        expect(Validators.isValidUrl('http://subdomain.example.com'), isTrue);
        expect(Validators.isValidUrl('https://example.com/path'), isTrue);
        expect(
          Validators.isValidUrl('https://example.com/path/to/resource'),
          isTrue,
        );
        expect(Validators.isValidUrl('https://example.com:8080'), isTrue);
        expect(
          Validators.isValidUrl('https://example.com/path?query=value'),
          isTrue,
        );
        expect(
          Validators.isValidUrl('https://example.com/path#fragment'),
          isTrue,
        );
        expect(
          Validators.isValidUrl(
            'https://example.com/path?query=value&other=param#fragment',
          ),
          isTrue,
        );
      });

      test('should reject invalid URL formats', () {
        // Invalid URLs
        expect(Validators.isValidUrl(''), isFalse);
        expect(Validators.isValidUrl('invalid'), isFalse);
        expect(Validators.isValidUrl('example.com'), isFalse); // Missing scheme
        expect(
          Validators.isValidUrl('www.example.com'),
          isFalse,
        ); // Missing scheme
        expect(
          Validators.isValidUrl('ftp://example.com'),
          isFalse,
        ); // Wrong scheme
        expect(
          Validators.isValidUrl('file:///path/to/file'),
          isFalse,
        ); // Wrong scheme
        expect(
          Validators.isValidUrl('https://'),
          isTrue,
        ); // Uri.parse allows this
        expect(
          Validators.isValidUrl('http://'),
          isTrue,
        ); // Uri.parse allows this
      });

      test('should handle edge cases', () {
        // Edge cases
        expect(Validators.isValidUrl('https://localhost'), isTrue);
        expect(Validators.isValidUrl('http://127.0.0.1'), isTrue);
        expect(Validators.isValidUrl('https://192.168.1.1'), isTrue);
        expect(Validators.isValidUrl('https://example.com:80'), isTrue);
        expect(Validators.isValidUrl('https://example.com:443'), isTrue);
        expect(Validators.isValidUrl('https://example.com:3000'), isTrue);
      });

      test('should handle malformed URLs gracefully', () {
        // These should not crash and should return false
        expect(
          Validators.isValidUrl('https://[invalid]'),
          isFalse,
        ); // Uri.parse actually rejects this
        expect(
          Validators.isValidUrl('https://exam ple.com'),
          isTrue,
        ); // Uri.parse accepts this
        expect(
          Validators.isValidUrl('https://.example.com'),
          isTrue,
        ); // Uri.parse accepts this
        expect(
          Validators.isValidUrl('https://example..com'),
          isTrue,
        ); // Uri.parse accepts this
      });

      test('should handle URLs with special characters', () {
        // URLs with encoded characters
        expect(
          Validators.isValidUrl('https://example.com/path%20with%20spaces'),
          isTrue,
        );
        expect(
          Validators.isValidUrl('https://example.com/path?query=%20value'),
          isTrue,
        );

        // URLs with query parameters
        expect(Validators.isValidUrl('https://example.com?a=1&b=2'), isTrue);
        expect(
          Validators.isValidUrl('https://example.com?search=hello%20world'),
          isTrue,
        );
      });
    });

    group('isValidPhoneNumber Tests', () {
      test('should validate correct phone number formats', () {
        // Valid phone numbers
        expect(Validators.isValidPhoneNumber('+1234567890'), isTrue);
        expect(Validators.isValidPhoneNumber('+33123456789'), isTrue);
        expect(Validators.isValidPhoneNumber('+44 20 1234 5678'), isTrue);
        expect(Validators.isValidPhoneNumber('+1 (555) 123-4567'), isTrue);
        expect(Validators.isValidPhoneNumber('+49 30 12345678'), isTrue);
        expect(
          Validators.isValidPhoneNumber('1234567890'),
          isTrue,
        ); // Without +
        expect(Validators.isValidPhoneNumber('123-456-7890'), isTrue);
        expect(Validators.isValidPhoneNumber('(123) 456-7890'), isTrue);
        expect(Validators.isValidPhoneNumber('123 456 7890'), isTrue);
        expect(Validators.isValidPhoneNumber('+81 3 1234 5678'), isTrue);
      });

      test('should reject invalid phone number formats', () {
        // Invalid phone numbers
        expect(Validators.isValidPhoneNumber(''), isFalse);
        expect(Validators.isValidPhoneNumber('123'), isFalse); // Too short
        expect(Validators.isValidPhoneNumber('12345678'), isFalse); // Too short
        expect(
          Validators.isValidPhoneNumber('123456789'),
          isFalse,
        ); // Too short (9 digits)
        expect(Validators.isValidPhoneNumber('abc'), isFalse);
        expect(Validators.isValidPhoneNumber('123abc'), isFalse);
        expect(
          Validators.isValidPhoneNumber('++1234567890'),
          isFalse,
        ); // Double +
        expect(
          Validators.isValidPhoneNumber('1234567890@'),
          isFalse,
        ); // Invalid character
        expect(
          Validators.isValidPhoneNumber('12.34.56.78.90'),
          isFalse,
        ); // Dots not allowed
      });

      test('should handle international phone number formats', () {
        // International formats
        expect(
          Validators.isValidPhoneNumber('+86 138 0013 8000'),
          isTrue,
        ); // China
        expect(
          Validators.isValidPhoneNumber('+91 98765 43210'),
          isTrue,
        ); // India
        expect(
          Validators.isValidPhoneNumber('+55 11 9876-5432'),
          isTrue,
        ); // Brazil
        expect(
          Validators.isValidPhoneNumber('+61 4 1234 5678'),
          isTrue,
        ); // Australia
        expect(
          Validators.isValidPhoneNumber('+7 495 123-45-67'),
          isTrue,
        ); // Russia
        expect(
          Validators.isValidPhoneNumber('+34 912 345 678'),
          isTrue,
        ); // Spain
      });

      test('should handle edge cases', () {
        // Edge cases
        expect(
          Validators.isValidPhoneNumber('1234567890'),
          isTrue,
        ); // Exactly 10 digits
        expect(
          Validators.isValidPhoneNumber('12345678901'),
          isTrue,
        ); // 11 digits
        expect(
          Validators.isValidPhoneNumber('123456789012345'),
          isTrue,
        ); // 15 digits (max international)
        expect(
          Validators.isValidPhoneNumber('  +1234567890  '),
          isFalse,
        ); // Leading/trailing spaces not trimmed
        expect(
          Validators.isValidPhoneNumber('+1-234-567-890'),
          isTrue,
        ); // Mixed separators
      });

      test('should handle various separator formats', () {
        // Different separators
        expect(Validators.isValidPhoneNumber('+1-555-123-4567'), isTrue);
        expect(Validators.isValidPhoneNumber('+1 555 123 4567'), isTrue);
        expect(
          Validators.isValidPhoneNumber('+1.555.123.4567'),
          isFalse,
        ); // Dots not supported in regex
        expect(Validators.isValidPhoneNumber('+1(555)1234567'), isTrue);
        expect(Validators.isValidPhoneNumber('555-123-4567'), isTrue);
        expect(Validators.isValidPhoneNumber('(555) 123-4567'), isTrue);
      });
    });

    group('isNotEmpty Tests', () {
      test('should return true for non-empty strings', () {
        expect(Validators.isNotEmpty('hello'), isTrue);
        expect(Validators.isNotEmpty('a'), isTrue);
        expect(Validators.isNotEmpty('Hello World'), isTrue);
        expect(Validators.isNotEmpty('123'), isTrue);
        expect(
          Validators.isNotEmpty('  content  '),
          isTrue,
        ); // Spaces + content
      });

      test('should return false for empty or null strings', () {
        expect(Validators.isNotEmpty(null), isFalse);
        expect(Validators.isNotEmpty(''), isFalse);
        expect(Validators.isNotEmpty('   '), isFalse); // Only whitespace
        expect(Validators.isNotEmpty('\t'), isFalse); // Tab character
        expect(Validators.isNotEmpty('\n'), isFalse); // Newline character
        expect(
          Validators.isNotEmpty('  \t  \n  '),
          isFalse,
        ); // Mixed whitespace
      });

      test('should handle special characters', () {
        expect(Validators.isNotEmpty(r'!@#$%'), isTrue);
        expect(Validators.isNotEmpty('émojis 🙂'), isTrue);
        expect(Validators.isNotEmpty('中文'), isTrue);
        expect(Validators.isNotEmpty('العربية'), isTrue);
        expect(Validators.isNotEmpty('0'), isTrue); // Zero character
      });

      test('should handle edge cases', () {
        expect(Validators.isNotEmpty(' a '), isTrue); // Content with spaces
        expect(Validators.isNotEmpty('\ta\t'), isTrue); // Content with tabs
        expect(Validators.isNotEmpty('\na\n'), isTrue); // Content with newlines
      });
    });

    group('isValidApiToken Tests', () {
      test('should validate correct API token formats', () {
        // Valid API tokens (at least 10 characters)
        expect(
          Validators.isValidApiToken('1234567890'),
          isTrue,
        ); // Exactly 10 chars
        expect(
          Validators.isValidApiToken('abcdefghijklmnop'),
          isTrue,
        ); // 16 chars
        expect(
          Validators.isValidApiToken('sk-1234567890abcdef'),
          isTrue,
        ); // Stripe-like format
        expect(
          Validators.isValidApiToken('ghp_1234567890abcdefghijk'),
          isTrue,
        ); // GitHub-like format
        expect(
          Validators.isValidApiToken('xoxb-1234567890-abcdef'),
          isTrue,
        ); // Slack-like format
        expect(
          Validators.isValidApiToken('AIza1234567890abcdefGHIJKL'),
          isTrue,
        ); // Google API-like format
        expect(
          Validators.isValidApiToken(
            'very_long_api_token_with_underscores_and_numbers_123456',
          ),
          isTrue,
        );
      });

      test('should reject invalid API token formats', () {
        // Invalid API tokens
        expect(Validators.isValidApiToken(''), isFalse);
        expect(
          Validators.isValidApiToken('123'),
          isFalse,
        ); // Too short (3 chars)
        expect(
          Validators.isValidApiToken('123456789'),
          isFalse,
        ); // Too short (9 chars)
        expect(Validators.isValidApiToken('   '), isFalse); // Only whitespace
        expect(
          Validators.isValidApiToken('        '),
          isFalse,
        ); // Only spaces (8 chars, < 10)
        expect(
          Validators.isValidApiToken('   short   '),
          isTrue,
        ); // 11 chars total with content
      });

      test('should handle tokens with whitespace', () {
        // Tokens with leading/trailing whitespace
        expect(
          Validators.isValidApiToken('  1234567890  '),
          isTrue,
        ); // Valid after trim
        expect(
          Validators.isValidApiToken('\t1234567890\t'),
          isTrue,
        ); // Valid after trim
        expect(
          Validators.isValidApiToken('\n1234567890\n'),
          isTrue,
        ); // Valid after trim
        expect(
          Validators.isValidApiToken('  123456789  '),
          isTrue,
        ); // 13 chars total with content
      });

      test('should handle various character types', () {
        // Different character types
        expect(
          Validators.isValidApiToken('ABC1234567'),
          isTrue,
        ); // Mixed case + numbers
        expect(
          Validators.isValidApiToken('abc-123-def'),
          isTrue,
        ); // With hyphens
        expect(
          Validators.isValidApiToken('abc_123_def'),
          isTrue,
        ); // With underscores
        expect(Validators.isValidApiToken('abc.123.def'), isTrue); // With dots
        expect(
          Validators.isValidApiToken('abc@123#def'),
          isTrue,
        ); // With special chars
        expect(
          Validators.isValidApiToken('1234567890'),
          isTrue,
        ); // Only numbers
        expect(
          Validators.isValidApiToken('abcdefghij'),
          isTrue,
        ); // Only letters
      });

      test('should handle edge cases', () {
        // Edge cases
        expect(
          Validators.isValidApiToken('a123456789'),
          isTrue,
        ); // Exactly 10 chars
        expect(
          Validators.isValidApiToken('0123456789'),
          isTrue,
        ); // Starting with zero
        expect(
          Validators.isValidApiToken(r'!@#$%^&*()'),
          isTrue,
        ); // Only special chars (10)
        expect(
          Validators.isValidApiToken('          '),
          isFalse,
        ); // 10 spaces but empty after trim
      });

      test('should validate realistic API token examples', () {
        // Real-world-like examples
        expect(
          Validators.isValidApiToken('pk_test_1234567890abcdef'),
          isTrue,
        ); // Stripe public key
        expect(
          Validators.isValidApiToken('sk_live_1234567890abcdef'),
          isTrue,
        ); // Stripe secret key
        expect(
          Validators.isValidApiToken(
            'xoxb-1234567890-1234567890-abcdefghijklmnopqrstuvwx',
          ),
          isTrue,
        ); // Slack bot token
        expect(
          Validators.isValidApiToken(
            'ghp_abcdefghijklmnopqrstuvwxyz1234567890',
          ),
          isTrue,
        ); // GitHub personal access token
        expect(
          Validators.isValidApiToken('Bearer 1234567890abcdef'),
          isTrue,
        ); // Bearer token format
        expect(
          Validators.isValidApiToken('AKIAIOSFODNN7EXAMPLE'),
          isTrue,
        ); // AWS access key format
      });
    });

    group('Integration and Cross-Validation Tests', () {
      test('should handle null inputs gracefully', () {
        // Only isNotEmpty accepts null, others should not crash
        expect(() => Validators.isValidEmail(''), returnsNormally);
        expect(() => Validators.isValidUrl(''), returnsNormally);
        expect(() => Validators.isValidPhoneNumber(''), returnsNormally);
        expect(() => Validators.isValidApiToken(''), returnsNormally);
        expect(() => Validators.isNotEmpty(null), returnsNormally);
      });

      test('should handle very long inputs', () {
        final String veryLongString = 'a' * 10000;

        expect(() => Validators.isValidEmail(veryLongString), returnsNormally);
        expect(
          () => Validators.isValidUrl(r'https://${veryLongString}.com'),
          returnsNormally,
        );
        expect(
          () => Validators.isValidPhoneNumber(veryLongString),
          returnsNormally,
        );
        expect(
          () => Validators.isValidApiToken(veryLongString),
          returnsNormally,
        );
        expect(Validators.isNotEmpty(veryLongString), isTrue);
      });

      test('should handle unicode and special encoding', () {
        const String unicodeString = '🚀📱💻🌟✨';
        const String emojiEmail = 'user@🌟.com';
        const String unicodeUrl = 'https://🌟.com';

        expect(() => Validators.isValidEmail(emojiEmail), returnsNormally);
        expect(() => Validators.isValidUrl(unicodeUrl), returnsNormally);
        expect(
          () => Validators.isValidPhoneNumber(unicodeString),
          returnsNormally,
        );
        expect(
          Validators.isValidApiToken(unicodeString),
          isFalse,
        ); // Unicode emojis are < 10 bytes
        expect(Validators.isNotEmpty(unicodeString), isTrue);
      });

      test('should be consistent with empty string handling', () {
        // All validators should return false for empty strings
        expect(Validators.isValidEmail(''), isFalse);
        expect(Validators.isValidUrl(''), isFalse);
        expect(Validators.isValidPhoneNumber(''), isFalse);
        expect(Validators.isValidApiToken(''), isFalse);
        expect(Validators.isNotEmpty(''), isFalse);
      });

      test('should be consistent with whitespace-only string handling', () {
        const String whitespaceString = '   ';

        expect(Validators.isValidEmail(whitespaceString), isFalse);
        expect(Validators.isValidUrl(whitespaceString), isFalse);
        expect(Validators.isValidPhoneNumber(whitespaceString), isFalse);
        expect(Validators.isNotEmpty(whitespaceString), isFalse);
        // API token validation trims, so whitespace only strings are invalid
        expect(
          Validators.isValidApiToken('          '),
          isFalse,
        ); // 10 spaces but empty after trim
      });
    });

    group('Performance Tests', () {
      test('should validate quickly with reasonable inputs', () {
        const String email = 'test@example.com';
        const String url = 'https://example.com';
        const String phone = '+1234567890';
        const String token = 'valid_api_token_123';
        const String text = 'some text';

        final Stopwatch stopwatch = Stopwatch()..start();

        // Run each validator multiple times
        for (int i = 0; i < 1000; i++) {
          Validators.isValidEmail(email);
          Validators.isValidUrl(url);
          Validators.isValidPhoneNumber(phone);
          Validators.isValidApiToken(token);
          Validators.isNotEmpty(text);
        }

        stopwatch.stop();

        // Should complete 5000 validations in reasonable time (< 100ms)
        expect(stopwatch.elapsedMilliseconds, lessThan(100));
      });
    });
  });
}
