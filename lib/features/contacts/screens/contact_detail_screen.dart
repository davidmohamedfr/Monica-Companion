import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      Logger.debug('Contact ${_currentContact.id} readOnly=$readOnly');
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
    final Contact? updatedContact = await showDialog<Contact>(
      context: context,
      builder: (BuildContext context) =>
          EditContactDialog(contact: _currentContact),
    );

    if (updatedContact != null && mounted) {
      context.read<ContactsBloc>().add(UpdateContactEvent(updatedContact));
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
