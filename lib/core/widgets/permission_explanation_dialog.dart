import 'package:flutter/material.dart';

/// Dialog explaining why WRITE_CONTACTS permission is needed
class PermissionExplanationDialog extends StatelessWidget {
  const PermissionExplanationDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Permission Required'),
      content: SingleChildScrollView(
        child: Text(
          'Companion needs WRITE_CONTACTS permission to sync contacts between '
          'your phone and Monica.\n\n'
          'Without this permission, the app will run in read-only mode and '
          'cannot update your phone contacts.',
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Continue Read-Only'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop(true);
          },
          child: const Text('Grant Permission'),
        ),
      ],
    );
  }
}
