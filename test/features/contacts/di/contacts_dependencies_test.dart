import 'package:flutter_test/flutter_test.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:monica_companion/features/contacts/di/contacts_dependencies.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';
import 'package:monica_companion/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('ContactsDependencies - PermissionService Integration', () {
    late ServiceLocator serviceLocator;

    setUp(() {
      serviceLocator = ServiceLocator.instance;
      // Clear service locator before each test
      serviceLocator.clear();
    });

    tearDown(() {
      serviceLocator.clear();
    });

    test(
      'ContactsServiceImpl should be registered with PermissionService',
      () async {
        // Arrange
        SharedPreferences.setMockInitialValues(<String, Object>{});

        // Act
        await ContactsDependencies.registerDependencies();
        final ContactsService contactsService = serviceLocator
            .get<ContactsService>();

        // Assert
        expect(contactsService, isA<ContactsServiceImpl>());

        // Verify PermissionService is injected by checking if isContactReadOnly
        // correctly checks app-level read-only mode
        // Since we can't inspect private fields, we'll verify behavior
        // by checking that the method returns false when permissions granted
        final bool readOnly = await contactsService.isContactReadOnly('test');

        // Should return false when PermissionService is properly injected
        // and no denial count exists
        expect(readOnly, isFalse);
      },
    );

    test('PermissionService should be registered in service locator', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{});

      // Act
      await ContactsDependencies.registerDependencies();

      // Assert
      expect(() => serviceLocator.get<PermissionService>(), returnsNormally);
      expect(
        serviceLocator.get<PermissionService>(),
        isA<PermissionServiceImpl>(),
      );
    });

    test('ContactsRepository should work with PermissionService', () async {
      // Arrange
      SharedPreferences.setMockInitialValues(<String, Object>{});

      // Act
      await ContactsDependencies.registerDependencies();
      final ContactsRepository repository = serviceLocator
          .get<ContactsRepository>();

      // Assert - should not throw when checking read-only status
      expect(() => repository.isContactReadOnly('test'), returnsNormally);
    });
  });
}
