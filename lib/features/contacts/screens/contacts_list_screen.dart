import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_bloc.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';
import 'package:monica_companion/features/contacts/widgets/contact_card_item.dart';
import 'package:monica_companion/features/contacts/widgets/contact_grid_item.dart';
import 'package:monica_companion/features/contacts/widgets/contact_list_item.dart';
import 'package:monica_companion/features/contacts/widgets/contacts_filter_bar.dart';
import 'package:monica_companion/features/contacts/widgets/contacts_search_bar.dart';
import 'package:monica_companion/features/contacts/widgets/contacts_view_mode_selector.dart';
import 'package:monica_companion/features/shared/widgets/empty_state_widget.dart';
import 'package:monica_companion/features/shared/widgets/error_widget.dart';
import 'package:monica_companion/features/shared/widgets/loading_widget.dart';

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    context.read<ContactsBloc>().add(const LoadContactsEvent());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ContactsBloc>().add(const RefreshContactsEvent());
            },
            tooltip: 'Refresh contacts',
          ),
        ],
      ),
      body: BlocBuilder<ContactsBloc, ContactsState>(
        builder: (BuildContext context, ContactsState state) => Column(
            children: <Widget>[
              ContactsSearchBar(
                onSearchChanged: (String query) {
                  context.read<ContactsBloc>().add(SearchContactsEvent(query));
                },
                initialValue: state.searchQuery,
              ),
              ContactsFilterBar(
                currentFilter: state.currentFilter,
                onFilterChanged: (ContactFilter filter) {
                  context.read<ContactsBloc>().add(FilterContactsEvent(filter));
                },
              ),
              ContactsViewModeSelector(
                currentViewMode: state.currentViewMode,
                onViewModeChanged: (ContactViewMode viewMode) {
                  context.read<ContactsBloc>()
                      .add(ChangeViewModeEvent(viewMode));
                },
              ),
              Expanded(
                child: _buildContactsList(context, state),
              ),
            ],
          ),
        ),
      );

  Widget _buildContactsList(BuildContext context, ContactsState state) {
    if (state.isLoading && state.contacts.isEmpty) {
      return const AppLoadingWidget(message: 'Loading contacts...');
    }

    if (state.errorMessage != null && state.contacts.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () {
          context.read<ContactsBloc>().add(const LoadContactsEvent());
        },
      );
    }

    if (state.filteredContacts.isEmpty && !state.isLoading) {
      if (state.searchQuery.isNotEmpty ||
          state.currentFilter != ContactFilter.all) {
        return EmptyStateWidget(
          icon: Icons.search_off,
          title: 'No contacts found',
          message: _getEmptyMessage(state),
          action: ElevatedButton(
            onPressed: () {
              context.read<ContactsBloc>()
                ..add(const SearchContactsEvent(''))
                ..add(const FilterContactsEvent(ContactFilter.all));
            },
            child: const Text('Clear filters'),
          ),
        );
      } else {
        return const EmptyStateWidget(
          icon: Icons.contacts,
          title: 'No contacts',
          message: 'Your contact list is empty.',
        );
      }
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<ContactsBloc>().add(const RefreshContactsEvent());
      },
      child: _buildContactsView(context, state),
    );
  }

  Widget _buildContactsView(BuildContext context, ContactsState state) {
    switch (state.currentViewMode) {
      case ContactViewMode.list:
        return _buildListView(state.filteredContacts);
      case ContactViewMode.grid:
        return _buildGridView(state.filteredContacts);
      case ContactViewMode.card:
        return _buildCardView(state.filteredContacts);
    }
  }

  Widget _buildListView(List<Contact> contacts) => ListView.builder(
      controller: _scrollController,
      itemCount: contacts.length,
      itemBuilder: (BuildContext context, int index) {
        final Contact contact = contacts[index];
        return ContactListItem(
          contact: contact,
          onTap: () => _navigateToContactDetail(contact),
        );
      },
    );

  Widget _buildGridView(List<Contact> contacts) => GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: contacts.length,
      itemBuilder: (BuildContext context, int index) {
        final Contact contact = contacts[index];
        return ContactGridItem(
          contact: contact,
          onTap: () => _navigateToContactDetail(contact),
        );
      },
    );

  Widget _buildCardView(List<Contact> contacts) => ListView.builder(
      controller: _scrollController,
      itemCount: contacts.length,
      itemBuilder: (BuildContext context, int index) {
        final Contact contact = contacts[index];
        return ContactCardItem(
          contact: contact,
          onTap: () => _navigateToContactDetail(contact),
        );
      },
    );

  String _getEmptyMessage(ContactsState state) {
    if (state.searchQuery.isNotEmpty &&
        state.currentFilter != ContactFilter.all) {
      return 'No contacts match your search "${state.searchQuery}" '
          'with filter "${state.currentFilter.displayName}".';
    } else if (state.searchQuery.isNotEmpty) {
      return 'No contacts match your search "${state.searchQuery}".';
    } else {
      return 'No contacts match the selected filter '
          '"${state.currentFilter.displayName}".';
    }
  }

  void _navigateToContactDetail(Contact contact) {
    // TODO(developer): Implement contact detail navigation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Contact detail for ${contact.name} (Coming soon)'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
