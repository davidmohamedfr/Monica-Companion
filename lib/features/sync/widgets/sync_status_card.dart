import 'package:flutter/material.dart';

/// Sync status card widget
class SyncStatusCard extends StatelessWidget {
  const SyncStatusCard({
    required this.isOnline, required this.lastSyncTime, required this.pendingChanges, super.key,
  });

  final bool isOnline;
  final String lastSyncTime;
  final int pendingChanges;

  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Last sync: $lastSyncTime',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (pendingChanges > 0) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                'Pending changes: $pendingChanges',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
}