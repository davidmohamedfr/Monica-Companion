import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monica_companion/core/utils/communication_utils.dart';
import 'package:monica_companion/core/utils/logger.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:monica_companion/features/contacts/widgets/contact_info_section.dart';
import 'package:monica_companion/features/contacts/widgets/edit_contact_dialog.dart';
import 'package:monica_companion/features/shared/widgets/empty_state_widget.dart';

class ContactDetailScreen extends StatefulWidget {
  const ContactDetailScreen({required this.contact, super.key});

  final Contact contact;

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _currentContact;
  bool _isReadOnly = false;
  bool _isCheckingReadOnly = true;

  @override
  void initState() {
    super.initState();
    _currentContact = widget.contact;
    _checkReadOnlyStatus();
  }

  Future<void> _checkReadOnlyStatus() async {
    try {
      final ContactsRepository repository = context.read<ContactsRepository>();
      final bool readOnly = await repository.isContactReadOnly(
        _currentContact.id,
      );
      if (mounted) {
        setState(() {
          _isReadOnly = readOnly;
          _isCheckingReadOnly = false;
        });
      }
    } catch (e) {
      Logger.error('Error checking read-only status', error: e);
      if (mounted) {
        setState(() {
          _isReadOnly = true; // Assume read-only on error
          _isCheckingReadOnly = false;
        });
      }
    }
  }

  Future<void> _showEditDialog() async {
    // Get repository and bloc from current context before showing dialog
    final ContactsRepository repository = context.read<ContactsRepository>();
    final ContactsBloc bloc = context.read<ContactsBloc>();

    final Contact? updatedContact = await showDialog<Contact>(
      context: context,
      builder: (BuildContext context) =>
          RepositoryProvider<ContactsRepository>.value(
            value: repository,
            child: EditContactDialog(contact: _currentContact),
          ),
    );

    if (updatedContact != null && mounted) {
      bloc.add(UpdateContactEvent(updatedContact));
      setState(() {
        _currentContact = updatedContact;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact updated successfully')),
        );
      }
    }
  }

  Future<void> _makePhoneCall() async {
    if (_currentContact.phone == null || _currentContact.phone!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available')),
        );
      }
      return;
    }

    final bool success = await CommunicationUtils.makePhoneCall(
      _currentContact.phone!,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to make phone call')),
      );
    }
  }

  Future<void> _sendSMS() async {
    if (_currentContact.phone == null || _currentContact.phone!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No phone number available')),
        );
      }
      return;
    }

    final bool success = await CommunicationUtils.sendSMS(
      _currentContact.phone!,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open messaging app')),
      );
    }
  }

  Future<void> _sendEmail() async {
    if (_currentContact.email == null || _currentContact.email!.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No email address available')),
        );
      }
      return;
    }

    final bool success = await CommunicationUtils.sendEmail(
      _currentContact.email!,
    );
    if (!success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to open email app')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentContact.name),
        actions: <Widget>[
          if (!_isCheckingReadOnly && !_isReadOnly)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _showEditDialog,
              tooltip: 'Edit contact',
            ),
          GestureDetector(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feature coming soon - see issue #65'),
                ),
              );
            },
            child: IconButton(
              icon: const Icon(Icons.block),
              onPressed: null,
              tooltip: 'Coming soon - Add to exclusion list',
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ContactInfoSection(contact: _currentContact),
              const SizedBox(height: 24),
              // Communication action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (_currentContact.phone != null &&
                      _currentContact.phone!.isNotEmpty) ...<Widget>[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _makePhoneCall,
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sendSMS,
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  if (_currentContact.email != null &&
                      _currentContact.email!.isNotEmpty)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _sendEmail,
                        icon: const Icon(Icons.email),
                        label: const Text('Email'),
                      ),
                    ),
                ],
              ),
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
