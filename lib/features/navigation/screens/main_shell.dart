import 'package:flutter/material.dart';
import 'package:monica_companion/features/calls/screens/calls_screen.dart';
import 'package:monica_companion/features/contacts/screens/contacts_screen.dart';
import 'package:monica_companion/features/navigation/widgets/bottom_navigation_bar.dart';
import 'package:monica_companion/features/settings/screens/settings_screen.dart';
import 'package:monica_companion/features/sync/screens/sync_screen.dart';

/// Main app shell with bottom navigation
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  Widget _getScreen(int index) {
    switch (index) {
      case 0:
        return const ContactsScreen();
      case 1:
        return const CallsScreen();
      case 2:
        return const SettingsScreen();
      case 3:
        return const SyncScreen();
      default:
        return const ContactsScreen();
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: _getScreen(_selectedIndex),
    bottomNavigationBar: MonicaBottomNavigationBar(
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    ),
  );
}
