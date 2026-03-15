import 'package:flutter_test/flutter_test.dart';
import 'package:venturelink/core/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('returns null for valid email', () {
      expect(Validators.email('user@example.com'), isNull);
    });

    test('returns error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
    });

    test('returns error for empty email', () {
      expect(Validators.email(''), isNotNull);
    });
  });

  group('Validators.password', () {
    test('returns null for valid password', () {
      expect(Validators.password('Secure123'), isNull);
    });

    test('returns error for short password', () {
      expect(Validators.password('Ab1'), isNotNull);
    });

    test('returns error for no uppercase', () {
      expect(Validators.password('secure123'), isNotNull);
    });

    test('returns error for no number', () {
      expect(Validators.password('SecurePass'), isNotNull);
    });
  });

  group('Validators.positiveNumber', () {
    test('returns null for valid positive number', () {
      expect(Validators.positiveNumber('100'), isNull);
    });

    test('returns error for zero', () {
      expect(Validators.positiveNumber('0'), isNotNull);
    });

    test('returns error for negative number', () {
      expect(Validators.positiveNumber('-5'), isNotNull);
    });

    test('returns error for non-numeric', () {
      expect(Validators.positiveNumber('abc'), isNotNull);
    });
  });

  group('Validators.url', () {
    test('returns null for valid https URL', () {
      expect(Validators.url('https://example.com'), isNull);
    });

    test('returns null for empty URL (optional)', () {
      expect(Validators.url(''), isNull);
    });

    test('returns error for URL without protocol', () {
      expect(Validators.url('example.com'), isNotNull);
    });
  });
}