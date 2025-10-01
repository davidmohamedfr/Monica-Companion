import 'package:flutter/material.dart';

/// Calls screen - displays call log
class CallsScreen extends StatelessWidget {
  const CallsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Calls'),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO(user): Implement filter functionality
          },
        ),
      ],
    ),
    body: const Center(child: Text('Calls Screen - Coming Soon')),
  );
}
