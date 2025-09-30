import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';

class ContactCardItem extends StatelessWidget {
  const ContactCardItem({required this.contact, this.onTap, super.key});

  final Contact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              _buildAvatar(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            contact.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (contact.isFavorite)
                          Icon(
                            Icons.favorite,
                            color: theme.colorScheme.primary,
                            size: 20,
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildContactDetails(theme),
                    if (contact.needsInteractionSoon) ...<Widget>[
                      const SizedBox(height: 8),
                      _buildInteractionChip(theme),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() => CircleAvatar(
    radius: 28,
    backgroundImage: contact.photoUrl != null
        ? NetworkImage(contact.photoUrl!)
        : null,
    child: contact.photoUrl == null
        ? Text(
            _getInitials(contact.name),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          )
        : null,
  );

  Widget _buildContactDetails(ThemeData theme) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: <Widget>[
      if (contact.phone != null)
        Row(
          children: <Widget>[
            Icon(
              Icons.phone,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                contact.phone!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      if (contact.phone != null && contact.email != null)
        const SizedBox(height: 4),
      if (contact.email != null)
        Row(
          children: <Widget>[
            Icon(
              Icons.email,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                contact.email!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      if (contact.lastContactedAt != null) ...<Widget>[
        const SizedBox(height: 4),
        Row(
          children: <Widget>[
            Icon(
              Icons.access_time,
              size: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              'Last contact: ${_formatDate(contact.lastContactedAt!)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ],
    ],
  );

  Widget _buildInteractionChip(ThemeData theme) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: theme.colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      'Needs interaction soon',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w500,
      ),
    ),
  );

  String _getInitials(String name) {
    final List<String> words = name.trim().split(' ');
    if (words.isEmpty) {
      return '?';
    }

    if (words.length == 1) {
      return words[0].isNotEmpty ? words[0][0].toUpperCase() : '?';
    }

    return (words[0].isNotEmpty ? words[0][0] : '') +
        (words[1].isNotEmpty ? words[1][0] : '');
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    final Duration difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final int weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final int months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }
}
