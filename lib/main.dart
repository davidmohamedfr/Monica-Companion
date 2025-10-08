import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monica_companion/core/services/app_initialization_service.dart';
import 'package:monica_companion/core/services/permission_service.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/navigation/screens/main_shell.dart';
import 'package:monica_companion/services/service_locator.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize application services
  try {
    await AppInitializationService.instance.initialize();

    // Request permissions on first launch
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final PermissionService permissionService = ServiceLocator.instance
        .get<PermissionService>();
    final AppInitializationService appInitService =
        AppInitializationService.withDependencies(
          prefs: prefs,
          permissionService: permissionService,
        );
    await appInitService.requestPermissionsOnFirstLaunch();

    runApp(const MonicaApp());
  } catch (e) {
    // In a production app, you might want to show an error screen
    // For now, we'll just rethrow to crash the app with proper logging
    rethrow;
  }
}

class MonicaApp extends StatelessWidget {
  const MonicaApp({super.key});

  // Monica brand color constant
  static const Color _monicaBrandColor = Color(0xFF6366F1);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Monica Companion',
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _monicaBrandColor,
      ).copyWith(primary: _monicaBrandColor),
      useMaterial3: true,
    ),
    home: MultiRepositoryProvider(
      providers: <RepositoryProvider<dynamic>>[
        RepositoryProvider<ContactsRepository>(
          create: (BuildContext context) =>
              ServiceLocator.instance.get<ContactsRepository>(),
        ),
      ],
      child: BlocProvider<ContactsBloc>(
        create: (BuildContext context) =>
            ServiceLocator.instance.get<ContactsBloc>(),
        child: const MainShell(),
      ),
    ),
  );
}
