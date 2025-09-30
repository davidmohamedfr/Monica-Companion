import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';
import 'package:monica_companion/features/shared/models/feature_state.dart';

class ContactsState extends FeatureState {
  const ContactsState({
    this.contacts = const <Contact>[],
    this.filteredContacts = const <Contact>[],
    this.searchQuery = '',
    this.currentFilter = ContactFilter.all,
    this.currentViewMode = ContactViewMode.list,
    this.isLoading = false,
    this.errorMessage,
  });

  final List<Contact> contacts;
  final List<Contact> filteredContacts;
  final String searchQuery;
  final ContactFilter currentFilter;
  final ContactViewMode currentViewMode;
  final bool isLoading;
  final String? errorMessage;

  ContactsState copyWith({
    List<Contact>? contacts,
    List<Contact>? filteredContacts,
    String? searchQuery,
    ContactFilter? currentFilter,
    ContactViewMode? currentViewMode,
    bool? isLoading,
    String? errorMessage,
  }) => ContactsState(
      contacts: contacts ?? this.contacts,
      filteredContacts: filteredContacts ?? this.filteredContacts,
      searchQuery: searchQuery ?? this.searchQuery,
      currentFilter: currentFilter ?? this.currentFilter,
      currentViewMode: currentViewMode ?? this.currentViewMode,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );

  ContactsState clearError() => copyWith();

  @override
  List<Object?> get props => <Object?>[
        contacts,
        filteredContacts,
        searchQuery,
        currentFilter,
        currentViewMode,
        isLoading,
        errorMessage,
      ];
}
