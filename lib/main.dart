import 'package:flutter/material.dart';

void main() {
  runApp(const MonicaMobileApp());
}

class MonicaMobileApp extends StatelessWidget {
  const MonicaMobileApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monica Mobile App',
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
        title: const Text('Monica Mobile App'),
      ),
      body: const Center(
        child: Text('Welcome to Monica Mobile App'),
      ),
    );
  }
}