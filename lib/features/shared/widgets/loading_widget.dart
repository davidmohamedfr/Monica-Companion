import 'package:flutter/material.dart';

/// Reusable loading widget for displaying loading states consistently
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({this.message, this.size = 32, super.key});

  final String? message;
  final double size;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: theme.colorScheme.primary,
            ),
          ),
          if (message != null) ...<Widget>[
            const SizedBox(height: 16),
            Text(
              message!,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Loading widget for list items
class ListLoadingWidget extends StatelessWidget {
  const ListLoadingWidget({super.key});

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(16),
    child: AppLoadingWidget(message: 'Loading...', size: 24),
  );
}
