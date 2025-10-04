import 'package:equatable/equatable.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';
import 'package:monica_companion/features/contacts/models/contact_model.dart';
import 'package:monica_companion/features/contacts/models/contact_sort_order.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';

abstract class ContactsEvent extends Equatable {
  const ContactsEvent();

  @override
  List<Object?> get props => <Object?>[];
}

class LoadContactsEvent extends ContactsEvent {
  const LoadContactsEvent();
}

class SearchContactsEvent extends ContactsEvent {
  const SearchContactsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => <Object?>[query];
}

class FilterContactsEvent extends ContactsEvent {
  const FilterContactsEvent(this.filter);

  final ContactFilter filter;

  @override
  List<Object?> get props => <Object?>[filter];
}

class ChangeViewModeEvent extends ContactsEvent {
  const ChangeViewModeEvent(this.viewMode);

  final ContactViewMode viewMode;

  @override
  List<Object?> get props => <Object?>[viewMode];
}

class RefreshContactsEvent extends ContactsEvent {
  const RefreshContactsEvent();
}

class ChangeSortOrderEvent extends ContactsEvent {
  const ChangeSortOrderEvent(this.sortOrder);

  final ContactSortOrder sortOrder;

  @override
  List<Object?> get props => <Object?>[sortOrder];
}

class UpdateContactEvent extends ContactsEvent {
  const UpdateContactEvent(this.contact);

  final Contact contact;

  @override
  List<Object?> get props => <Object?>[contact];
}
