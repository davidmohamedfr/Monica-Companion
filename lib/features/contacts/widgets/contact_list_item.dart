import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';

class ContactListItem extends StatelessWidget {
  const ContactListItem({
    required this.contact,
    this.onTap,
    super.key,
  });

  final Contact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ListTile(
      leading: _buildAvatar(),
      title: Text(
        contact.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: _buildSubtitle(theme),
      trailing: contact.isFavorite
          ? Icon(
              Icons.favorite,
              color: theme.colorScheme.primary,
              size: 20,
            )
          : null,
      onTap: onTap,
      dense: false,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }

  Widget _buildAvatar() => CircleAvatar(
      radius: 24,
      backgroundImage: contact.photoUrl != null
          ? NetworkImage(contact.photoUrl!)
          : null,
      child: contact.photoUrl == null
          ? Text(
              _getInitials(contact.name),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            )
          : null,
    );

  Widget? _buildSubtitle(ThemeData theme) {
    final List<String> subtitleParts = <String>[];

    if (contact.phone != null) {
      subtitleParts.add(contact.phone!);
    }

    if (contact.email != null) {
      subtitleParts.add(contact.email!);
    }

    if (subtitleParts.isEmpty) {
      return null;
    }

    return Text(
      subtitleParts.join(' • '),
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

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
}
