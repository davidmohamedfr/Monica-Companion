import 'package:flutter/material.dart';
import 'package:monica_companion/features/sync/widgets/sync_status_card.dart';

/// Sync screen - displays sync status and controls
class SyncScreen extends StatelessWidget {
  const SyncScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Sync'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // TODO: Implement manual sync
            },
          ),
        ],
      ),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: <Widget>[
            SyncStatusCard(
              isOnline: true,
              lastSyncTime: '2 hours ago',
              pendingChanges: 5,
            ),
            SizedBox(height: 24),
            Expanded(
              child: Center(
                child: Text('Sync Screen - Coming Soon'),
              ),
            ),
          ],
        ),
      ),
    );
}