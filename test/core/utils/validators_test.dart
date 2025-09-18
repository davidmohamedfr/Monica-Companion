import 'package:flutter_test/flutter_test.dart';
import 'package:monica_mobile_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('isValidEmail', () {
      test('should return true for valid email addresses', () {
        expect(Validators.isValidEmail('test@example.com'), isTrue);
        expect(Validators.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(Validators.isValidEmail('test+tag@example.org'), isTrue);
      });

      test('should return false for invalid email addresses', () {
        expect(Validators.isValidEmail('invalid-email'), isFalse);
        expect(Validators.isValidEmail('test@'), isFalse);
        expect(Validators.isValidEmail('@example.com'), isFalse);
        expect(Validators.isValidEmail(''), isFalse);
      });
    });

    group('isValidUrl', () {
      test('should return true for valid URLs', () {
        expect(Validators.isValidUrl('https://example.com'), isTrue);
        expect(Validators.isValidUrl('http://test.org'), isTrue);
        expect(Validators.isValidUrl('https://api.domain.com/path'), isTrue);
      });

      test('should return false for invalid URLs', () {
        expect(Validators.isValidUrl('not-a-url'), isFalse);
        expect(Validators.isValidUrl('ftp://example.com'), isFalse);
        expect(Validators.isValidUrl(''), isFalse);
      });
    });

    group('isValidPhoneNumber', () {
      test('should return true for valid phone numbers', () {
        expect(Validators.isValidPhoneNumber('+1234567890'), isTrue);
        expect(Validators.isValidPhoneNumber('123-456-7890'), isTrue);
        expect(Validators.isValidPhoneNumber('(123) 456-7890'), isTrue);
      });

      test('should return false for invalid phone numbers', () {
        expect(Validators.isValidPhoneNumber('123'), isFalse);
        expect(Validators.isValidPhoneNumber('abc'), isFalse);
        expect(Validators.isValidPhoneNumber(''), isFalse);
      });
    });

    group('isNotEmpty', () {
      test('should return true for non-empty strings', () {
        expect(Validators.isNotEmpty('test'), isTrue);
        expect(Validators.isNotEmpty('test with spaces'), isTrue);
      });

      test('should return false for empty or null strings', () {
        expect(Validators.isNotEmpty(''), isFalse);
        expect(Validators.isNotEmpty('   '), isFalse);
        expect(Validators.isNotEmpty(null), isFalse);
      });
    });

    group('isValidApiToken', () {
      test('should return true for valid API tokens', () {
        expect(Validators.isValidApiToken('valid-token-123'), isTrue);
        expect(Validators.isValidApiToken('abcdefghijk'), isTrue);
      });

      test('should return false for invalid API tokens', () {
        expect(Validators.isValidApiToken('short'), isFalse);
        expect(Validators.isValidApiToken(''), isFalse);
        expect(Validators.isValidApiToken('   '), isFalse);
      });
    });
  });
}
