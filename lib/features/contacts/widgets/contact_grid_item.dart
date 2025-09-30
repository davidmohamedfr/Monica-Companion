import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';

class ContactGridItem extends StatelessWidget {
  const ContactGridItem({required this.contact, this.onTap, super.key});

  final Contact contact;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.all(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Stack(
                children: <Widget>[
                  _buildAvatar(),
                  if (contact.isFavorite)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: theme.colorScheme.onPrimary,
                          size: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                contact.name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (contact.phone != null || contact.email != null) ...<Widget>[
                const SizedBox(height: 4),
                _buildContactInfo(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() => CircleAvatar(
    radius: 32,
    backgroundImage: contact.photoUrl != null
        ? NetworkImage(contact.photoUrl!)
        : null,
    child: contact.photoUrl == null
        ? Text(
            _getInitials(contact.name),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          )
        : null,
  );

  Widget _buildContactInfo(ThemeData theme) {
    String contactInfo = '';

    if (contact.phone != null) {
      contactInfo = contact.phone!;
    } else if (contact.email != null) {
      contactInfo = contact.email!;
    }

    return Text(
      contactInfo,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
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
