import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/db/models/debt.dart';

void main() {
  group('Debt Model', () {
    const int testContactId = 1;
    const double testAmount = 150.50;
    const String testCurrency = 'EUR';
    const DebtType testType = DebtType.owedToMe;
    const String testDate = '2024-01-15T10:00:00.000Z';
    const String testDescription = 'Lunch money from last week';
    const bool testPaid = true;

    test('should create Debt with required fields', () {
      const Debt debt = Debt(
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
      );

      expect(debt.contactId, testContactId);
      expect(debt.amount, testAmount);
      expect(debt.type, testType);
      expect(debt.date, testDate);
      expect(debt.currency, 'USD'); // Default value
      expect(debt.paid, false); // Default value
      expect(debt.id, isNull);
      expect(debt.description, isNull);
      expect(debt.createdAt, isNull);
    });

    test('should create Debt with all fields', () {
      final DateTime now = DateTime.now();
      final Debt debt = Debt(
        id: 1,
        contactId: testContactId,
        amount: testAmount,
        currency: testCurrency,
        type: testType,
        date: testDate,
        description: testDescription,
        paid: testPaid,
        createdAt: now,
      );

      expect(debt.id, 1);
      expect(debt.contactId, testContactId);
      expect(debt.amount, testAmount);
      expect(debt.currency, testCurrency);
      expect(debt.type, testType);
      expect(debt.date, testDate);
      expect(debt.description, testDescription);
      expect(debt.paid, testPaid);
      expect(debt.createdAt, now);
    });

    test('should convert Debt to Map correctly', () {
      final DateTime now = DateTime.now();
      final Debt debt = Debt(
        id: 1,
        contactId: testContactId,
        amount: testAmount,
        currency: testCurrency,
        type: testType,
        date: testDate,
        description: testDescription,
        paid: testPaid,
        createdAt: now,
      );

      final Map<String, dynamic> map = debt.toMap();

      expect(map['id'], 1);
      expect(map['contact_id'], testContactId);
      expect(map['amount'], testAmount);
      expect(map['currency'], testCurrency);
      expect(map['type'], 'owed_to_me'); // Enum value as string
      expect(map['date'], testDate);
      expect(map['description'], testDescription);
      expect(map['paid'], 1); // Boolean stored as int
      expect(map['created_at'], now.toIso8601String());
    });

    test('should create Debt from Map correctly', () {
      final DateTime now = DateTime.now();
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'amount': testAmount,
        'currency': testCurrency,
        'type': 'owed_to_me',
        'date': testDate,
        'description': testDescription,
        'paid': 1,
        'created_at': now.toIso8601String(),
      };

      final Debt debt = Debt.fromMap(map);

      expect(debt.id, 1);
      expect(debt.contactId, testContactId);
      expect(debt.amount, testAmount);
      expect(debt.currency, testCurrency);
      expect(debt.type, DebtType.owedToMe);
      expect(debt.date, testDate);
      expect(debt.description, testDescription);
      expect(debt.paid, true);
      expect(debt.createdAt, now);
    });

    test('should handle null values in fromMap', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'amount': testAmount,
        'type': 'owed_to_me',
        'date': testDate,
        'currency': null,
        'description': null,
        'paid': null,
        'created_at': null,
      };

      final Debt debt = Debt.fromMap(map);

      expect(debt.id, 1);
      expect(debt.contactId, testContactId);
      expect(debt.amount, testAmount);
      expect(debt.type, DebtType.owedToMe);
      expect(debt.date, testDate);
      expect(debt.currency, 'USD'); // Default value when null
      expect(debt.description, isNull);
      expect(debt.paid, false); // null treated as false
      expect(debt.createdAt, isNull);
    });

    test('copyWith should create new instance with updated fields', () {
      const Debt original = Debt(
        id: 1,
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
        paid: false,
      );

      final Debt updated = original.copyWith(
        amount: 200.0,
        currency: testCurrency,
        type: DebtType.iOwe,
        description: testDescription,
        paid: testPaid,
      );

      expect(updated.id, 1);
      expect(updated.contactId, testContactId);
      expect(updated.amount, 200.0);
      expect(updated.currency, testCurrency);
      expect(updated.type, DebtType.iOwe);
      expect(updated.date, testDate);
      expect(updated.description, testDescription);
      expect(updated.paid, testPaid);
      expect(original.amount, testAmount); // Original should be unchanged
      expect(original.type, testType); // Original should be unchanged
      expect(original.paid, false); // Original should be unchanged
    });

    test('should implement Equatable correctly', () {
      const Debt debt1 = Debt(
        id: 1,
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
      );

      const Debt debt2 = Debt(
        id: 1,
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
      );

      const Debt debt3 = Debt(
        id: 2,
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
      );

      expect(debt1, equals(debt2));
      expect(debt1, isNot(equals(debt3)));
      expect(debt1.hashCode, equals(debt2.hashCode));
    });

    test('should handle DebtType enum correctly', () {
      // Test owedToMe
      const Debt owedToMeDebt = Debt(
        contactId: testContactId,
        amount: testAmount,
        type: DebtType.owedToMe,
        date: testDate,
      );

      final Map<String, dynamic> owedToMeMap = owedToMeDebt.toMap();
      expect(owedToMeMap['type'], 'owed_to_me');

      final Debt owedToMeFromMap = Debt.fromMap(owedToMeMap);
      expect(owedToMeFromMap.type, DebtType.owedToMe);

      // Test iOwe
      const Debt iOweDebt = Debt(
        contactId: testContactId,
        amount: testAmount,
        type: DebtType.iOwe,
        date: testDate,
      );

      final Map<String, dynamic> iOweMap = iOweDebt.toMap();
      expect(iOweMap['type'], 'i_owe');

      final Debt iOweFromMap = Debt.fromMap(iOweMap);
      expect(iOweFromMap.type, DebtType.iOwe);
    });

    test('should handle boolean paid field correctly', () {
      // Test true value
      const Debt paidDebt = Debt(
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
        paid: true,
      );

      final Map<String, dynamic> paidMap = paidDebt.toMap();
      expect(paidMap['paid'], 1);

      final Debt paidFromMap = Debt.fromMap(paidMap);
      expect(paidFromMap.paid, true);

      // Test false value
      const Debt unpaidDebt = Debt(
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
        paid: false,
      );

      final Map<String, dynamic> unpaidMap = unpaidDebt.toMap();
      expect(unpaidMap['paid'], 0);

      final Debt unpaidFromMap = Debt.fromMap(unpaidMap);
      expect(unpaidFromMap.paid, false);
    });

    test('should handle different currencies', () {
      const List<String> currencies = ['USD', 'EUR', 'GBP', 'JPY', 'CAD'];

      for (final String currency in currencies) {
        final Debt debt = Debt(
          contactId: testContactId,
          amount: testAmount,
          currency: currency,
          type: testType,
          date: testDate,
        );

        expect(debt.currency, currency);

        final Map<String, dynamic> map = debt.toMap();
        final Debt fromMap = Debt.fromMap(map);

        expect(fromMap.currency, currency);
      }
    });

    test('should handle various amounts', () {
      const List<double> amounts = [0.01, 1.0, 25.50, 100.0, 999.99, 10000.0];

      for (final double amount in amounts) {
        final Debt debt = Debt(
          contactId: testContactId,
          amount: amount,
          type: testType,
          date: testDate,
        );

        expect(debt.amount, amount);

        final Map<String, dynamic> map = debt.toMap();
        final Debt fromMap = Debt.fromMap(map);

        expect(fromMap.amount, amount);
      }
    });

    test('should use default values when not specified', () {
      const Debt debt = Debt(
        contactId: testContactId,
        amount: testAmount,
        type: testType,
        date: testDate,
      );

      expect(debt.currency, 'USD');
      expect(debt.paid, false);

      final Map<String, dynamic> map = debt.toMap();
      expect(map['currency'], 'USD');
      expect(map['paid'], 0);
    });

    test('should handle DebtType.fromString correctly', () {
      expect(DebtType.fromString('owed_to_me'), DebtType.owedToMe);
      expect(DebtType.fromString('i_owe'), DebtType.iOwe);
      expect(DebtType.fromString('invalid'), DebtType.owedToMe); // Default fallback
    });

    test('should handle paid conversion from different int values', () {
      final Map<String, dynamic> map = <String, dynamic>{
        'id': 1,
        'contact_id': testContactId,
        'amount': testAmount,
        'currency': testCurrency,
        'type': 'owed_to_me',
        'date': testDate,
        'description': testDescription,
        'paid': 0,
        'created_at': null,
      };

      // Test with 0 (should be false)
      final Debt debt0 = Debt.fromMap(map);
      expect(debt0.paid, false);

      // Test with 1 (should be true)
      map['paid'] = 1;
      final Debt debt1 = Debt.fromMap(map);
      expect(debt1.paid, true);

      // Test with other positive int (should be false, only 1 is true)
      map['paid'] = 5;
      final Debt debt5 = Debt.fromMap(map);
      expect(debt5.paid, false);
    });

    test('should handle precise decimal amounts', () {
      const List<double> preciseAmounts = [
        12.34,
        99.99,
        123.456,
        0.001,
      ];

      for (final double amount in preciseAmounts) {
        final Debt debt = Debt(
          contactId: testContactId,
          amount: amount,
          type: testType,
          date: testDate,
        );

        final Map<String, dynamic> map = debt.toMap();
        final Debt fromMap = Debt.fromMap(map);

        expect(fromMap.amount, closeTo(amount, 0.001));
      }
    });
  });
}