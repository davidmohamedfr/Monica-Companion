import 'package:flutter/material.dart';
import 'package:monica_companion/core/errors/exceptions.dart';
import 'package:monica_companion/core/utils/error_transformer.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/models/contact.dart';
import 'package:monica_companion/db/repositories/repository_registry.dart';
import 'package:monica_companion/features/contacts/widgets/contact_list_item.dart';
import 'package:monica_companion/services/service_locator.dart';

/// Contacts screen - displays list of contacts
class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  late final ContactRepository _contactRepository;
  List<Contact> _contacts = <Contact>[];
  bool _isLoading = true;
  String? _errorMessage;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializeRepository();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading && _contacts.isEmpty && !_hasError) {
      _loadContacts();
    }
  }

  void _initializeRepository() {
    final RepositoryRegistry registry = ServiceLocator.instance.get<RepositoryRegistry>();
    _contactRepository = registry.contactRepository;
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final List<Contact> contacts = await _contactRepository.findAll();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
        _hasError = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });

      _handleError(e);
    }
  }

  void _handleError(Object error) {
    String userMessage;

    if (error is DatabaseException) {
      final failure = ErrorTransformer.transformException(error, 'loading contacts');
      userMessage = ErrorTransformer.getUserFriendlyMessage(failure);
    } else {
      final failure = ErrorTransformer.transformException(error, 'loading contacts');
      userMessage = ErrorTransformer.getUserFriendlyMessage(failure);
    }

    setState(() {
      _errorMessage = userMessage;
    });

    // Use addPostFrameCallback to ensure the widget is fully built before showing SnackBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(userMessage),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: _loadContacts,
            ),
            duration: const Duration(seconds: 6),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              // TODO: Implement add contact functionality
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _hasError
              ? _buildErrorState()
              : _contacts.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      itemCount: _contacts.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Contact contact = _contacts[index];
                        return ContactListItem(
                          name: contact.name,
                          email: contact.email,
                          phone: contact.phone,
                          avatarUrl: contact.avatar,
                          onTap: () {
                            // TODO: Navigate to contact details
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Unable to load contacts',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unexpected error occurred',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadContacts,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.people_outline,
              size: 64,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No contacts yet',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first contact to get started',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implement add contact functionality
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
            ),
          ],
        ),
      ),
    );
  }
}