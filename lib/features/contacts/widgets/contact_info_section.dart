import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';

class ContactInfoSection extends StatelessWidget {
  const ContactInfoSection({required this.contact, super.key});

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      children: <Widget>[
        const SizedBox(height: 24),
        _buildAvatar(theme),
        const SizedBox(height: 32),
        _buildInfoItems(theme),
      ],
    );
  }

  Widget _buildAvatar(ThemeData theme) => Stack(
    children: <Widget>[
      CircleAvatar(
        radius: 60,
        backgroundImage: contact.photoUrl != null
            ? NetworkImage(contact.photoUrl!)
            : null,
        child: contact.photoUrl == null
            ? Text(
                _getInitials(contact.name),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w500,
                ),
              )
            : null,
      ),
      if (contact.isFavorite)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.favorite,
              color: theme.colorScheme.primary,
              size: 24,
            ),
          ),
        ),
    ],
  );

  Widget _buildInfoItems(ThemeData theme) => Column(
    children: <Widget>[
      if (contact.phone != null)
        _buildInfoItem(icon: Icons.phone, value: contact.phone!, theme: theme),
      if (contact.email != null)
        _buildInfoItem(icon: Icons.email, value: contact.email!, theme: theme),
      if (contact.lastContactedAt != null)
        _buildInfoItem(
          icon: Icons.calendar_today,
          value: _formatDate(contact.lastContactedAt!),
          theme: theme,
        ),
      if (contact.notes != null && contact.notes!.isNotEmpty)
        _buildNotesItem(theme),
    ],
  );

  Widget _buildInfoItem({
    required IconData icon,
    required String value,
    required ThemeData theme,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Row(
      children: <Widget>[
        Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 16),
        Expanded(child: Text(value, style: theme.textTheme.bodyLarge)),
      ],
    ),
  );

  Widget _buildNotesItem(ThemeData theme) => Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  Icons.notes,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text('Notes', style: theme.textTheme.titleSmall),
              ],
            ),
            const SizedBox(height: 8),
            Text(contact.notes!, style: theme.textTheme.bodyMedium),
          ],
        ),
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

    final String first = words[0].isNotEmpty ? words[0][0].toUpperCase() : '';
    final String last = words[1].isNotEmpty ? words[1][0].toUpperCase() : '';
    return first + last;
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
