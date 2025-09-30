import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:monica_companion/core/utils/logger.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_event.dart';
import 'package:monica_companion/features/contacts/bloc/contacts_state.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';
import 'package:monica_companion/features/contacts/repositories/contacts_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsBloc extends Bloc<ContactsEvent, ContactsState> {
  ContactsBloc({
    required ContactsRepository contactsRepository,
    required SharedPreferences sharedPreferences,
  })  : _contactsRepository = contactsRepository,
        _sharedPreferences = sharedPreferences,
        super(const ContactsState()) {
    on<LoadContactsEvent>(_onLoadContacts);
    on<SearchContactsEvent>(_onSearchContacts);
    on<FilterContactsEvent>(_onFilterContacts);
    on<ChangeViewModeEvent>(_onChangeViewMode);
    on<RefreshContactsEvent>(_onRefreshContacts);

    _loadSavedViewMode();
  }

  final ContactsRepository _contactsRepository;
  final SharedPreferences _sharedPreferences;
  Timer? _debounceTimer;

  static const String _viewModeKey = 'contacts_view_mode';


  void _loadSavedViewMode() {
    final int? savedViewModeIndex = _sharedPreferences.getInt(_viewModeKey);
    if (savedViewModeIndex != null) {
      final ContactViewMode viewMode =
          ContactViewMode.values[savedViewModeIndex];
      add(ChangeViewModeEvent(viewMode));
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

      emit(state.copyWith(
        contacts: contacts,
        filteredContacts: filteredContacts,
        isLoading: false,
      ));
    } on Exception catch (e) {
      Logger.error('Failed to load contacts', error: e);
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load contacts: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSearchContacts(
    SearchContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      _debounceTimer?.cancel();
      emit(state.copyWith(searchQuery: event.query));

      if (event.query.isEmpty) {
        final List<Contact> filteredContacts =
          _applyCurrentFilters(state.contacts);
        emit(state.copyWith(filteredContacts: filteredContacts));
        return;
      }

      _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
        try {
          final List<Contact> searchResults =
              await _contactsRepository.searchAndFilterContacts(
            event.query,
            state.currentFilter,
          );

          if (!emit.isDone) {
            emit(state.copyWith(filteredContacts: searchResults));
          }
        } on Exception catch (e) {
          Logger.error('Failed to search contacts', error: e);
          if (!emit.isDone) {
            emit(state.copyWith(
              errorMessage: 'Failed to search contacts: ${e.toString()}',
            ));
          }
        }
      });
    } on Exception catch (e) {
      Logger.error('Failed to search contacts', error: e);
      emit(state.copyWith(
        errorMessage: 'Failed to search contacts: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFilterContacts(
    FilterContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    try {
      emit(state.copyWith(currentFilter: event.filter));

      if (state.searchQuery.isNotEmpty) {
        final List<Contact> searchResults =
            await _contactsRepository.searchAndFilterContacts(
              state.searchQuery,
              event.filter,
            );
        emit(state.copyWith(filteredContacts: searchResults));
      } else {
        final List<Contact> filteredContacts =
            await _contactsRepository.filterContacts(event.filter);
        emit(state.copyWith(filteredContacts: filteredContacts));
      }
    } on Exception catch (e) {
      Logger.error('Failed to filter contacts', error: e);
      emit(state.copyWith(
        errorMessage: 'Failed to filter contacts: ${e.toString()}',
      ));
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

  Future<void> _onRefreshContacts(
    RefreshContactsEvent event,
    Emitter<ContactsState> emit,
  ) async {
    add(const LoadContactsEvent());
  }

  List<Contact> _applyCurrentFilters(List<Contact> contacts) {
    switch (state.currentFilter) {
      case ContactFilter.all:
        return contacts;
      case ContactFilter.favorites:
        return contacts.where((Contact contact) => contact.isFavorite).toList();
      case ContactFilter.recentlyContacted:
        final DateTime now = DateTime.now();
        const Duration recentThreshold = Duration(days: 30);
        return contacts.where((Contact contact) {
          final DateTime? lastContacted = contact.lastContactedAt;
          return lastContacted != null &&
                 now.difference(lastContacted) <= recentThreshold;
        }).toList();
      case ContactFilter.needsInteraction:
        return contacts
            .where((Contact contact) => contact.needsInteractionSoon)
            .toList();
    }
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
