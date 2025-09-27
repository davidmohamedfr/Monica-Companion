import 'package:flutter/material.dart';
import 'package:monica_companion/features/settings/widgets/settings_section.dart';

/// Settings screen - displays app settings
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: const <Widget>[
          SettingsSection(
            title: 'Account',
            children: <Widget>[
              ListTile(
                title: Text('Profile'),
                leading: Icon(Icons.person),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                title: Text('Privacy'),
                leading: Icon(Icons.lock),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
          SettingsSection(
            title: 'Data & Sync',
            children: <Widget>[
              ListTile(
                title: Text('Sync Settings'),
                leading: Icon(Icons.sync),
                trailing: Icon(Icons.chevron_right),
              ),
              ListTile(
                title: Text('Backup & Restore'),
                leading: Icon(Icons.backup),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
          SettingsSection(
            title: 'About',
            children: <Widget>[
              ListTile(
                title: Text('Version'),
                subtitle: Text('1.0.0'),
                leading: Icon(Icons.info),
              ),
              ListTile(
                title: Text('Help & Support'),
                leading: Icon(Icons.help),
                trailing: Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
}