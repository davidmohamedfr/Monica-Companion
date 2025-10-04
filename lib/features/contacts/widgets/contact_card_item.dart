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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          child: Row(
            children: <Widget>[
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                    if (_getPrimaryContactMethod() != null) ...<Widget>[
                      const SizedBox(height: 2),
                      _buildPrimaryContactMethod(theme),
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
    radius: 20,
    backgroundImage: contact.photoUrl != null
        ? NetworkImage(contact.photoUrl!)
        : null,
    child: contact.photoUrl == null
        ? Text(
            _getInitials(contact.name),
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          )
        : null,
  );

  String? _getPrimaryContactMethod() {
    if (contact.phone != null) {
      return contact.phone;
    }
    if (contact.email != null) {
      return contact.email;
    }
    return null;
  }

  IconData _getContactMethodIcon() {
    if (contact.phone != null) {
      return Icons.phone;
    }
    return Icons.email;
  }

  Widget _buildPrimaryContactMethod(ThemeData theme) => Row(
    children: <Widget>[
      Icon(
        _getContactMethodIcon(),
        size: 16,
        color: theme.colorScheme.onSurfaceVariant,
      ),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          _getPrimaryContactMethod()!,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
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
}
