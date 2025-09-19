import 'package:flutter/material.dart';
import 'package:monica_mobile_app/core/config/app_config.dart';
import 'package:monica_mobile_app/core/config/environment.dart';
import 'package:monica_mobile_app/config/feature_flags.dart';

void main() {
  runApp(const MonicaApp());
}

class MonicaApp extends StatelessWidget {
  const MonicaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(AppConfig.appName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Environment Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildConfigItem(
                'Environment', EnvironmentConfig.currentEnvironment.name),
            _buildConfigItem('App Name', AppConfig.appName),
            _buildConfigItem('API Base URL', AppConfig.apiBaseUrl),
            _buildConfigItem('Package Name', AppConfig.packageName),
            const SizedBox(height: 24),
            const Text(
              'Feature Flags',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...FeatureFlags.allFlags.entries.map(
              (entry) => _buildFeatureFlag(entry.key, entry.value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureFlag(String name, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            value == true ? Icons.check_circle : Icons.cancel,
            color: value == true ? Colors.green : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(name),
          const Spacer(),
          Text(
            value.toString(),
            style: TextStyle(
              color: value == true ? Colors.green : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
