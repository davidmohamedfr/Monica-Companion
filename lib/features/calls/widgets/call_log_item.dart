import 'package:flutter/material.dart';

/// Call log item widget
class CallLogItem extends StatelessWidget {
  const CallLogItem({
    required this.contactName,
    required this.callType,
    required this.timestamp,
    super.key,
    this.duration,
    this.onTap,
  });

  final String contactName;
  final String callType; // 'incoming', 'outgoing', 'missed'
  final DateTime timestamp;
  final Duration? duration;
  final VoidCallback? onTap;

  IconData get _callIcon {
    switch (callType.toLowerCase()) {
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'missed':
        return Icons.call_missed;
      default:
        return Icons.call;
    }
  }

  Color _getCallColor(BuildContext context) {
    switch (callType.toLowerCase()) {
      case 'incoming':
        return Theme.of(context).colorScheme.primary;
      case 'outgoing':
        return Theme.of(context).colorScheme.secondary;
      case 'missed':
        return Theme.of(context).colorScheme.error;
      default:
        return Theme.of(context).colorScheme.onSurface;
    }
  }

  String _formatDuration() {
    if (duration == null) return '';
    final int minutes = duration!.inMinutes;
    final int seconds = duration!.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  String _formatTimestamp() {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(_callIcon, color: _getCallColor(context)),
    title: Text(contactName),
    subtitle: Text(_formatTimestamp()),
    trailing: duration != null
        ? Text(_formatDuration(), style: Theme.of(context).textTheme.bodySmall)
        : null,
    onTap: onTap,
  );
}
