import 'package:flutter/material.dart';

import 'package:flutter_svg/flutter_svg.dart';
import 'package:monica_companion/core/config/app_config.dart';
import 'package:monica_companion/core/config/environment.dart';

void main() {
  runApp(const MonicaApp());
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
    home: const WelcomeScreen(),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Spacing constants
  static const double _mainPadding = 24;
  static const double _sectionSpacing = 40;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(_mainPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: _sectionSpacing),

                // Logo Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: SvgPicture.asset(
                    'assets/images/logos/monica_companion_logo.svg',
                    height: 120,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),

                const SizedBox(height: _sectionSpacing),

                // App Title
                Text(
                  'Monica Companion',
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Tagline
                Text(
                  'Personal relationships, perfectly managed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Description
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Welcome to Monica Companion - your mobile gateway to '
                    'meaningful relationships. Document your life, organize '
                    'interactions, and nurture the connections that matter '
                    'most.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: _sectionSpacing),

                // Development Info (temporary)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Development Build',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Environment: '
                        '${EnvironmentConfig.currentEnvironment.name}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                      Text(
                        'Package: ${AppConfig.packageName}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
