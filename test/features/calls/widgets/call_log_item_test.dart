import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/features/interactions/widgets/interaction_log_item.dart';

void main() {
  group('CallLogItem Widget', () {
    // Test data setup
    const String testContactName = 'John Doe';
    final DateTime testTimestamp = DateTime(2024, 1, 15, 14, 30);
    const Duration testDuration = Duration(minutes: 5, seconds: 30);

    Widget buildTestWidget({
      required String contactName,
      required String callType,
      required DateTime timestamp,
      Duration? duration,
      VoidCallback? onTap,
    }) => MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      home: Scaffold(
        body: CallLogItem(
          contactName: contactName,
          callType: callType,
          timestamp: timestamp,
          duration: duration,
          onTap: onTap,
        ),
      ),
    );

    group('Call Icon Display', () {
      testWidgets('should display correct icon for incoming call', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.call_received), findsOneWidget);
        expect(find.byIcon(Icons.call_made), findsNothing);
        expect(find.byIcon(Icons.call_missed), findsNothing);
      });

      testWidgets('should display correct icon for outgoing call', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'outgoing',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.call_made), findsOneWidget);
        expect(find.byIcon(Icons.call_received), findsNothing);
        expect(find.byIcon(Icons.call_missed), findsNothing);
      });

      testWidgets('should display correct icon for missed call', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'missed',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.call_missed), findsOneWidget);
        expect(find.byIcon(Icons.call_received), findsNothing);
        expect(find.byIcon(Icons.call_made), findsNothing);
      });

      testWidgets('should display default call icon for unknown call type', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'unknown',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.call), findsOneWidget);
      });

      testWidgets('should handle case-insensitive call types', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'INCOMING',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.byIcon(Icons.call_received), findsOneWidget);
      });
    });

    group('Call Icon Colors', () {
      testWidgets('should apply correct color for incoming call', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
          ),
        );

        // Act
        final Icon iconWidget = tester.widget<Icon>(
          find.byIcon(Icons.call_received),
        );
        final BuildContext context = tester.element(
          find.byIcon(Icons.call_received),
        );

        // Assert
        expect(iconWidget.color, Theme.of(context).colorScheme.primary);
      });

      testWidgets('should apply correct color for outgoing call', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'outgoing',
            timestamp: testTimestamp,
          ),
        );

        // Act
        final Icon iconWidget = tester.widget<Icon>(
          find.byIcon(Icons.call_made),
        );
        final BuildContext context = tester.element(
          find.byIcon(Icons.call_made),
        );

        // Assert
        expect(iconWidget.color, Theme.of(context).colorScheme.secondary);
      });

      testWidgets('should apply error color for missed call', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'missed',
            timestamp: testTimestamp,
          ),
        );

        // Act
        final Icon iconWidget = tester.widget<Icon>(
          find.byIcon(Icons.call_missed),
        );
        final BuildContext context = tester.element(
          find.byIcon(Icons.call_missed),
        );

        // Assert
        expect(iconWidget.color, Theme.of(context).colorScheme.error);
      });
    });

    group('Duration Display', () {
      testWidgets(
        'should display formatted duration when duration is provided',
        (WidgetTester tester) async {
          // Arrange
          await tester.pumpWidget(
            buildTestWidget(
              contactName: testContactName,
              callType: 'outgoing',
              timestamp: testTimestamp,
              duration: testDuration,
            ),
          );

          // Act & Assert
          expect(find.text('5:30'), findsOneWidget);
        },
      );

      testWidgets('should format zero seconds correctly', (
        WidgetTester tester,
      ) async {
        // Arrange
        const Duration zeroSecondsDuration = Duration(minutes: 3);
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'outgoing',
            timestamp: testTimestamp,
            duration: zeroSecondsDuration,
          ),
        );

        // Act & Assert
        expect(find.text('3:00'), findsOneWidget);
      });

      testWidgets('should format single digit seconds with leading zero', (
        WidgetTester tester,
      ) async {
        // Arrange
        const Duration singleDigitDuration = Duration(minutes: 2, seconds: 5);
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'outgoing',
            timestamp: testTimestamp,
            duration: singleDigitDuration,
          ),
        );

        // Act & Assert
        expect(find.text('2:05'), findsOneWidget);
      });

      testWidgets('should not display trailing widget when duration is null', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
          ),
        );

        // Act
        final ListTile listTile = tester.widget<ListTile>(
          find.byType(ListTile),
        );

        // Assert
        expect(listTile.trailing, isNull);
      });

      testWidgets('should handle very long durations correctly', (
        WidgetTester tester,
      ) async {
        // Arrange
        const Duration longDuration = Duration(minutes: 120, seconds: 45);
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'outgoing',
            timestamp: testTimestamp,
            duration: longDuration,
          ),
        );

        // Act & Assert
        expect(find.text('120:45'), findsOneWidget);
      });
    });

    group('Timestamp Formatting', () {
      testWidgets('should format today timestamp as time', (
        WidgetTester tester,
      ) async {
        // Arrange
        final DateTime todayTimestamp = DateTime.now().subtract(
          const Duration(hours: 2),
        );
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: todayTimestamp,
          ),
        );

        // Act & Assert
        final String expectedTime =
            '${todayTimestamp.hour}:'
            '${todayTimestamp.minute.toString().padLeft(2, '0')}';
        expect(find.text(expectedTime), findsOneWidget);
      });

      testWidgets('should display "Yesterday" for yesterday timestamp', (
        WidgetTester tester,
      ) async {
        // Arrange
        final DateTime yesterdayTimestamp = DateTime.now().subtract(
          const Duration(days: 1),
        );
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: yesterdayTimestamp,
          ),
        );

        // Act & Assert
        expect(find.text('Yesterday'), findsOneWidget);
      });

      testWidgets('should display days ago for recent dates', (
        WidgetTester tester,
      ) async {
        // Arrange
        final DateTime threeDaysAgo = DateTime.now().subtract(
          const Duration(days: 3),
        );
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: threeDaysAgo,
          ),
        );

        // Act & Assert
        expect(find.text('3 days ago'), findsOneWidget);
      });

      testWidgets('should format old dates as MM/dd/yyyy', (
        WidgetTester tester,
      ) async {
        // Arrange
        final DateTime oldTimestamp = DateTime.now().subtract(
          const Duration(days: 30),
        );
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: oldTimestamp,
          ),
        );

        // Act & Assert
        final String expectedDate =
            '${oldTimestamp.month}/${oldTimestamp.day}/${oldTimestamp.year}';
        expect(find.text(expectedDate), findsOneWidget);
      });
    });

    group('User Interaction', () {
      testWidgets('should call onTap callback when tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        bool tapCalled = false;
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
            onTap: () {
              tapCalled = true;
            },
          ),
        );

        // Act
        await tester.tap(find.byType(ListTile));
        await tester.pump();

        // Assert
        expect(tapCalled, isTrue);
      });

      testWidgets('should not crash when onTap is null and item is tapped', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert (should not throw)
        await tester.tap(find.byType(ListTile));
        await tester.pump();
        expect(find.byType(CallLogItem), findsOneWidget);
      });
    });

    group('Widget Structure', () {
      testWidgets('should display contact name in title', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.text(testContactName), findsOneWidget);
        final ListTile listTile = tester.widget<ListTile>(
          find.byType(ListTile),
        );
        expect(listTile.title, isA<Text>());
      });

      testWidgets('should use ListTile as base widget', (
        WidgetTester tester,
      ) async {
        // Arrange
        await tester.pumpWidget(
          buildTestWidget(
            contactName: testContactName,
            callType: 'incoming',
            timestamp: testTimestamp,
          ),
        );

        // Act & Assert
        expect(find.byType(ListTile), findsOneWidget);
      });
    });
  });
}
