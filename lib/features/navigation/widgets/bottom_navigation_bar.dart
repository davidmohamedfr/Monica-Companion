import 'package:flutter/material.dart';

/// Bottom navigation bar for the main app shell
class MonicaBottomNavigationBar extends StatelessWidget {
  const MonicaBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    super.key,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => NavigationBar(
    selectedIndex: currentIndex,
    onDestinationSelected: onTap,
    destinations: const <NavigationDestination>[
      NavigationDestination(
        icon: Icon(Icons.contacts_outlined),
        selectedIcon: Icon(Icons.contacts),
        label: 'Contacts',
      ),
      NavigationDestination(
        icon: Icon(Icons.call_outlined),
        selectedIcon: Icon(Icons.call),
        label: 'Calls',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Settings',
      ),
      NavigationDestination(
        icon: Icon(Icons.sync_outlined),
        selectedIcon: Icon(Icons.sync),
        label: 'Sync',
      ),
    ],
  );
}
