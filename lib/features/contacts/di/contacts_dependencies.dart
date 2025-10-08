import 'package:monica_companion/core/services/permission_service.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/services/contacts_service.dart';
import 'package:monica_companion/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsDependencies {
  static Future<void> registerDependencies() async {
    final ServiceLocator serviceLocator = ServiceLocator.instance;

    // Register SharedPreferences as singleton
    final SharedPreferences sharedPreferences =
        await SharedPreferences.getInstance();
    serviceLocator.registerSingleton<SharedPreferences>(sharedPreferences);

    // Register PermissionService
    serviceLocator.registerSingleton<PermissionService>(
      PermissionServiceImpl(sharedPreferences),
    );

    // Register ContactsService with PermissionService
    serviceLocator.registerSingleton<ContactsService>(
      ContactsServiceImpl(serviceLocator.get<PermissionService>()),
    );

    // Register ContactsRepository
    serviceLocator.registerFactory<ContactsRepository>(
      () => ContactsRepositoryImpl(serviceLocator.get<ContactsService>()),
    );

    // Register ContactsBloc factory
    serviceLocator.registerFactory<ContactsBloc>(
      () => ContactsBloc(
        contactsRepository: serviceLocator.get<ContactsRepository>(),
        sharedPreferences: serviceLocator.get<SharedPreferences>(),
      ),
    );
  }
}
