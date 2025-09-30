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
    serviceLocator
      ..registerSingleton<SharedPreferences>(sharedPreferences)
      // Register ContactsService
      ..registerSingleton<ContactsService>(ContactsServiceImpl())
      // Register ContactsRepository
      ..registerFactory<ContactsRepository>(
        () => ContactsRepositoryImpl(serviceLocator.get<ContactsService>()),
      )
      // Register ContactsBloc factory
      ..registerFactory<ContactsBloc>(
        () => ContactsBloc(
          contactsRepository: serviceLocator.get<ContactsRepository>(),
          sharedPreferences: serviceLocator.get<SharedPreferences>(),
        ),
      );
  }
}
