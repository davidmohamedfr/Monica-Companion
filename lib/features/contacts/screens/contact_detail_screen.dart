import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/widgets/contact_info_section.dart';
import 'package:monica_companion/features/shared/widgets/empty_state_widget.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({required this.contact, super.key});

  final Contact contact;

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.contact.name)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ContactInfoSection(contact: widget.contact),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              Text('Recent Interactions', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              const EmptyStateWidget(
                title: 'No interactions yet',
                message: 'Interactions will appear here in a future update',
                icon: Icons.history,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
