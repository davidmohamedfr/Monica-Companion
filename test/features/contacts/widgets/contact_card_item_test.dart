import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/widgets/contact_card_item.dart';

void main() {
  // Suppress network image errors in tests
  setUpAll(() {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Ignore NetworkImageLoadException errors in tests
      if (details.exception.toString().contains('NetworkImageLoadException')) {
        return;
      }
      FlutterError.presentError(details);
    };
  });

  group('ContactCardItem Widget Tests - Overflow Fix', () {
    // Test data
    late Contact basicContact;
    late Contact favoriteContact;
    late Contact contactWithLongName;
    late Contact contactWithLongPhone;
    late Contact contactWithBothPhoneAndEmail;
    late Contact contactWithOnlyEmail;
    late Contact contactWithLastContacted;
    late Contact contactNeedsInteraction;

    setUpAll(() {
      basicContact = const Contact(
        id: '1',
        name: 'John Doe',
        phone: '+1234567890',
      );

      favoriteContact = const Contact(
        id: '2',
        name: 'Jane Smith',
        phone: '+0987654321',
        email: 'jane.smith@example.com',
        isFavorite: true,
      );

      contactWithLongName = const Contact(
        id: '3',
        name: 'Very Long Contact Name That Should Be Truncated With Ellipsis',
        phone: '+1234567890',
      );

      contactWithLongPhone = const Contact(
        id: '4',
        name: 'Long Phone',
        phone: '+1-800-VERY-LONG-PHONE-NUMBER-FOR-TESTING-OVERFLOW',
      );

      contactWithBothPhoneAndEmail = const Contact(
        id: '5',
        name: 'Both Contact Methods',
        phone: '+1234567890',
        email: 'both@example.com',
      );

      contactWithOnlyEmail = const Contact(
        id: '6',
        name: 'Email Only',
        email: 'emailonly@example.com',
      );

      contactWithLastContacted = Contact(
        id: '7',
        name: 'Last Contacted',
        phone: '+1234567890',
        lastContactedAt: DateTime(2024, 1, 1),
      );

      contactNeedsInteraction = const Contact(
        id: '8',
        name: 'Needs Interaction',
        phone: '+1234567890',
        needsInteractionSoon: true,
      );
    });

    Widget createTestWidget(Contact contact, {VoidCallback? onTap}) =>
        MaterialApp(
          home: Scaffold(
            body: ContactCardItem(contact: contact, onTap: onTap),
          ),
        );

    group('Test 1: Height Constraints', () {
      testWidgets('should render without overflow in normal usage', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(basicContact));

        // Assert - Widget should render without overflow
        expect(tester.takeException(), isNull);
      });

      testWidgets('should render without overflow with long name', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(contactWithLongName));

        // Assert
        expect(tester.takeException(), isNull);
      });
    });

    group('Test 2: Avatar Size', () {
      testWidgets('should display avatar with 40px diameter (radius 20)', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(basicContact));

        // Assert
        final CircleAvatar avatar = tester.widget(find.byType(CircleAvatar));
        expect(avatar.radius, equals(20));
      });
    });

    group('Test 3: Name Text Constraints', () {
      testWidgets(
        'should display name with single line and ellipsis overflow',
        (WidgetTester tester) async {
          // Arrange & Act
          await tester.pumpWidget(createTestWidget(contactWithLongName));

          // Assert - Find the name text widget
          final Text nameText = tester.widget(
            find.text(
              'Very Long Contact Name That Should Be Truncated With Ellipsis',
            ),
          );
          expect(nameText.maxLines, equals(1));
          expect(nameText.overflow, equals(TextOverflow.ellipsis));
        },
      );

      testWidgets('should apply maxLines to name for all contacts', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(basicContact));

        // Assert
        final Text nameText = tester.widget(find.text('John Doe'));
        expect(nameText.maxLines, equals(1));
        expect(nameText.overflow, equals(TextOverflow.ellipsis));
      });
    });

    group('Test 4: Single Contact Method', () {
      testWidgets('should display only one contact method prioritizing phone', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(contactWithBothPhoneAndEmail));

        // Assert - Phone should be displayed
        expect(find.byIcon(Icons.phone), findsOneWidget);
        expect(find.text('+1234567890'), findsOneWidget);

        // Email should NOT be displayed
        expect(find.byIcon(Icons.email), findsNothing);
        expect(find.text('both@example.com'), findsNothing);
      });
    });

    group('Test 5: Contact Method Text Constraints', () {
      testWidgets(
        'should display contact method with single line and ellipsis overflow',
        (WidgetTester tester) async {
          // Arrange & Act
          await tester.pumpWidget(createTestWidget(contactWithLongPhone));

          // Assert - Find the phone text widget
          final Text phoneText = tester.widget(
            find.text('+1-800-VERY-LONG-PHONE-NUMBER-FOR-TESTING-OVERFLOW'),
          );
          expect(phoneText.maxLines, equals(1));
          expect(phoneText.overflow, equals(TextOverflow.ellipsis));
        },
      );
    });

    group('Test 6: No Last Contacted Date', () {
      testWidgets('should not display last contacted date in card view', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(contactWithLastContacted));

        // Assert
        expect(find.textContaining('Last contact'), findsNothing);
        expect(find.byIcon(Icons.access_time), findsNothing);
      });
    });

    group('Test 7: No Interaction Chip', () {
      testWidgets('should not display needs interaction chip in card view', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(contactNeedsInteraction));

        // Assert
        expect(find.text('Needs interaction soon'), findsNothing);
      });
    });

    group('Test 8: Favorite Icon Preserved', () {
      testWidgets('should display favorite icon for favorite contacts', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(favoriteContact));

        // Assert
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        final Icon favoriteIcon = tester.widget(find.byIcon(Icons.favorite));
        expect(favoriteIcon.size, equals(20));
      });

      testWidgets(
        'should not display favorite icon for non-favorite contacts',
        (WidgetTester tester) async {
          // Arrange & Act
          await tester.pumpWidget(createTestWidget(basicContact));

          // Assert
          expect(find.byIcon(Icons.favorite), findsNothing);
        },
      );
    });

    group('Test 9: Email Fallback', () {
      testWidgets('should display email when phone is not available', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(contactWithOnlyEmail));

        // Assert - Email should be displayed
        expect(find.byIcon(Icons.email), findsOneWidget);
        expect(find.text('emailonly@example.com'), findsOneWidget);

        // Phone should NOT be displayed
        expect(find.byIcon(Icons.phone), findsNothing);
      });

      testWidgets('should apply text constraints to email', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(contactWithOnlyEmail));

        // Assert
        final Text emailText = tester.widget(
          find.text('emailonly@example.com'),
        );
        expect(emailText.maxLines, equals(1));
        expect(emailText.overflow, equals(TextOverflow.ellipsis));
      });
    });

    group('Additional Edge Cases', () {
      testWidgets('should handle contact with no phone or email', (
        WidgetTester tester,
      ) async {
        // Arrange
        const Contact noContactInfo = Contact(id: '9', name: 'No Contact Info');

        // Act
        await tester.pumpWidget(createTestWidget(noContactInfo));

        // Assert - Should render without crashing
        expect(find.text('No Contact Info'), findsOneWidget);
        expect(find.byIcon(Icons.phone), findsNothing);
        expect(find.byIcon(Icons.email), findsNothing);
      });

      testWidgets('should maintain Card and InkWell structure', (
        WidgetTester tester,
      ) async {
        // Arrange & Act
        await tester.pumpWidget(createTestWidget(basicContact));

        // Assert
        expect(find.byType(Card), findsOneWidget);
        expect(find.byType(InkWell), findsOneWidget);
      });

      testWidgets('should call onTap when provided', (
        WidgetTester tester,
      ) async {
        // Arrange
        bool wasTapped = false;
        void onTap() => wasTapped = true;

        // Act
        await tester.pumpWidget(createTestWidget(basicContact, onTap: onTap));
        await tester.tap(find.byType(InkWell));

        // Assert
        expect(wasTapped, isTrue);
      });
    });
  });
}
