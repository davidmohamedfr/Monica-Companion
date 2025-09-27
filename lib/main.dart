import 'package:flutter/material.dart';

import 'package:monica_companion/core/services/app_initialization_service.dart';
import 'package:monica_companion/features/navigation/screens/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize application services
  try {
    await AppInitializationService.instance.initialize();
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
    home: const MainShell(),
  );
}
