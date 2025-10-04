import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monica_companion/core/utils/logger.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_sort_order.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({
    required ContactsRepository contactsRepository,
    required SharedPreferences sharedPreferences,
  }) : _contactsRepository = contactsRepository,
       _sharedPreferences = sharedPreferences,
       super(const ContactsState()) {
    on<LoadContactsEvent>(_onLoadContacts);
    on<SearchContactsEvent>(_onSearchContacts);
    on<FilterContactsEvent>(_onFilterContacts);
    on<ChangeViewModeEvent>(_onChangeViewMode);
    on<ChangeSortOrderEvent>(_onChangeSortOrder);
    on<RefreshContactsEvent>(_onRefreshContacts);
    on<UpdateContactEvent>(_onUpdateContact);

    _loadSavedViewMode();
    _loadSavedSortOrder();
  }

  final ContactsRepository _contactsRepository;
  final SharedPreferences _sharedPreferences;
  Timer? _debounceTimer;
  int _searchSequence = 0;

  static const String _viewModeKey = 'contacts_view_mode';
  static const String _sortOrderKey = 'contacts_sort_order';

  void _loadSavedViewMode() {
    final int? savedViewModeIndex = _sharedPreferences.getInt(_viewModeKey);
    if (savedViewModeIndex != null &&
        savedViewModeIndex >= 0 &&
        savedViewModeIndex < ContactViewMode.values.length) {
      final ContactViewMode viewMode =
          ContactViewMode.values[savedViewModeIndex];
      add(ChangeViewModeEvent(viewMode));
    }
  }

  void _loadSavedSortOrder() {
    final int? savedSortOrderIndex = _sharedPreferences.getInt(_sortOrderKey);
    if (savedSortOrderIndex != null &&
        savedSortOrderIndex >= 0 &&
        savedSortOrderIndex < ContactSortOrder.values.length) {
      final ContactSortOrder sortOrder =
          ContactSortOrder.values[savedSortOrderIndex];
      add(ChangeSortOrderEvent(sortOrder));
    }
  }

  Future<void> _onLoadContacts(
    LoadContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));

      final List<Contact> contacts = await _contactsRepository.getContacts();
      final List<Contact> filteredContacts = _applyCurrentFilters(contacts);

      emit(
        state.copyWith(
          contacts: contacts,
          filteredContacts: filteredContacts,
          isLoading: false,
        ),
      );
    } on Exception catch (e) {
      Logger.error('Failed to load contacts', error: e);
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load contacts: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onSearchContacts(
    SearchContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      _debounceTimer?.cancel();

      // Increment sequence to track latest request
      _searchSequence++;
      final int currentSequence = _searchSequence;

      emit(state.copyWith(searchQuery: event.query));

      if (event.query.isEmpty) {
        final List<Contact> filteredContacts = _applyCurrentFilters(
          state.contacts,
        );
        emit(state.copyWith(filteredContacts: filteredContacts));
        return;
      }

      // Use Completer for proper async debouncing
      final Completer<void> completer = Completer<void>();

      _debounceTimer = Timer(const Duration(milliseconds: 300), () {
        completer.complete();
      });

      await completer.future;

      // Check if bloc is still active, query hasn't changed, AND this is still the latest request
      if (!emit.isDone &&
          state.searchQuery == event.query &&
          currentSequence == _searchSequence) {
        final List<Contact> searchResults = await _contactsRepository
            .searchAndFilterContacts(event.query, state.currentFilter);

        // Double-check sequence hasn't changed during async operation
        if (!emit.isDone && currentSequence == _searchSequence) {
          final List<Contact> sortedResults = _applySorting(
            searchResults,
            state.currentSortOrder,
          );
          emit(state.copyWith(filteredContacts: sortedResults));
        }
      }
    } on Exception catch (e) {
      Logger.error('Failed to search contacts', error: e);
      emit(
        state.copyWith(
          errorMessage: 'Failed to search contacts: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onFilterContacts(
    FilterContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      emit(state.copyWith(currentFilter: event.filter));

      List<Contact> results;
      if (state.searchQuery.isNotEmpty) {
        results = await _contactsRepository.searchAndFilterContacts(
          state.searchQuery,
          event.filter,
        );
      } else {
        results = await _contactsRepository.filterContacts(event.filter);
      }

      final List<Contact> sortedResults = _applySorting(
        results,
        state.currentSortOrder,
      );
      emit(state.copyWith(filteredContacts: sortedResults));
    } on Exception catch (e) {
      Logger.error('Failed to filter contacts', error: e);
      emit(
        state.copyWith(
          errorMessage: 'Failed to filter contacts: ${e.toString()}',
        ),
      );
    }
  }

  Future<void> _onChangeViewMode(
    ChangeViewModeEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _sharedPreferences.setInt(_viewModeKey, event.viewMode.index);
      emit(state.copyWith(currentViewMode: event.viewMode));
    } on Exception catch (e) {
      Logger.error('Failed to save view mode preference', error: e);
    }
  }

  Future<void> _onChangeSortOrder(
    ChangeSortOrderEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      await _sharedPreferences.setInt(_sortOrderKey, event.sortOrder.index);
      final List<Contact> sortedContacts = _applySorting(
        state.filteredContacts,
        event.sortOrder,
      );
      emit(
        state.copyWith(
          currentSortOrder: event.sortOrder,
          filteredContacts: sortedContacts,
        ),
      );
    } on Exception catch (e) {
      Logger.error('Failed to save sort order preference', error: e);
    }
  }

  Future<void> _onRefreshContacts(
    RefreshContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    add(const LoadContactsEvent());
  }

  Future<void> _onUpdateContact(
    UpdateContactEvent event,
    Emitter<ContactsState> emit,
  ) async {
    final List<Contact> updatedContacts = state.contacts.map((Contact contact) {
      return contact.id == event.contact.id ? event.contact : contact;
    }).toList();

    final List<Contact> updatedFilteredContacts = state.filteredContacts.map((
      Contact contact,
    ) {
      return contact.id == event.contact.id ? event.contact : contact;
    }).toList();

    emit(
      state.copyWith(
        contacts: updatedContacts,
        filteredContacts: updatedFilteredContacts,
      ),
    );
  }

  List<Contact> _applyCurrentFilters(List<Contact> contacts) {
    List<Contact> filtered;
    switch (state.currentFilter) {
      case ContactFilter.all:
        filtered = contacts;
      case ContactFilter.favorites:
        filtered = contacts
            .where((Contact contact) => contact.isFavorite)
            .toList();
      case ContactFilter.recentlyContacted:
        final DateTime now = DateTime.now();
        const Duration recentThreshold = Duration(days: 30);
        filtered = contacts.where((Contact contact) {
          final DateTime? lastContacted = contact.lastContactedAt;
          return lastContacted != null &&
              now.difference(lastContacted) <= recentThreshold;
        }).toList();
      case ContactFilter.needsInteraction:
        filtered = contacts
            .where((Contact contact) => contact.needsInteractionSoon)
            .toList();
    }
    return _applySorting(filtered, state.currentSortOrder);
  }

  List<Contact> _applySorting(
    List<Contact> contacts,
    ContactSortOrder sortOrder,
  ) {
    final List<Contact> sortedList = List<Contact>.from(contacts);

    switch (sortOrder) {
      case ContactSortOrder.nameAscending:
        sortedList.sort((Contact a, Contact b) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        });
      case ContactSortOrder.nameDescending:
        sortedList.sort((Contact a, Contact b) {
          return b.name.toLowerCase().compareTo(a.name.toLowerCase());
        });
      case ContactSortOrder.lastInteractionRecent:
        sortedList.sort((Contact a, Contact b) {
          final DateTime? dateA = a.lastContactedAt;
          final DateTime? dateB = b.lastContactedAt;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          return dateB.compareTo(dateA);
        });
      case ContactSortOrder.lastInteractionOldest:
        sortedList.sort((Contact a, Contact b) {
          final DateTime? dateA = a.lastContactedAt;
          final DateTime? dateB = b.lastContactedAt;

          if (dateA == null && dateB == null) return 0;
          if (dateA == null) return 1;
          if (dateB == null) return -1;

          return dateA.compareTo(dateB);
        });
    }

    return sortedList;
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
