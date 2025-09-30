import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_filter.dart';

class ContactsFilterBar extends StatelessWidget {
  const ContactsFilterBar({
    required this.currentFilter,
    required this.onFilterChanged,
    super.key,
  });

  final ContactFilter currentFilter;
  final ValueChanged<ContactFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) => Container(
    height: 50,
    margin: const EdgeInsets.symmetric(vertical: 8),
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ContactFilter.values.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(width: 8),
      itemBuilder: (BuildContext context, int index) {
        final ContactFilter filter = ContactFilter.values[index];
        final bool isSelected = filter == currentFilter;

        return _buildFilterChip(context, filter, isSelected);
      },
    ),
  );

  Widget _buildFilterChip(
    BuildContext context,
    ContactFilter filter,
    bool isSelected,
  ) {
    final ThemeData theme = Theme.of(context);

    return FilterChip(
      label: Text(filter.displayName),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          onFilterChanged(filter);
        }
      },
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
      tooltip: filter.description,
    );
  }
}
