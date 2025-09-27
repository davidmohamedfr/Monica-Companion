import 'package:flutter/material.dart';

/// Contact list item widget
class ContactListItem extends StatelessWidget {
  const ContactListItem({
    required this.name, super.key,
    this.email,
    this.phone,
    this.avatarUrl,
    this.onTap,
  });

  final String name;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
        child: avatarUrl == null
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onPrimary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(name),
      subtitle: email != null || phone != null
          ? Text(
              <String?>[email, phone].where((String? s) => s != null && s.isNotEmpty).join(' • '),
            )
          : null,
      onTap: onTap,
    );
}