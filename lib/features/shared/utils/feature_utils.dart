import 'package:flutter/material.dart';

/// Utility functions for features
class FeatureUtils {
  FeatureUtils._();

  /// Show a snackbar with a message
  static void showSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 4),
  }) {
    final SnackBar snackBar = SnackBar(
      content: Text(message),
      action: action,
      backgroundColor: backgroundColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Show an error snackbar
  static void showErrorSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Theme.of(context).colorScheme.error,
      action: action,
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackBar(
    BuildContext context,
    String message, {
    SnackBarAction? action,
  }) {
    showSnackBar(
      context,
      message,
      backgroundColor: Colors.green,
      action: action,
    );
  }

  /// Format DateTime to user-friendly string
  static String formatDateTime(DateTime dateTime) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} '
          'ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} '
          'ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} '
          'minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  /// Show confirmation dialog
  static Future<bool> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
  }) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(confirmText),
          ),
        ],
      ),
    );

    return result ?? false;
  }
}
