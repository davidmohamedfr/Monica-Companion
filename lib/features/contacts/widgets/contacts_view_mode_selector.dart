import 'package:flutter/material.dart';
import 'package:monica_companion/features/contacts/models/contact_view_mode.dart';

class ContactsViewModeSelector extends StatelessWidget {
  const ContactsViewModeSelector({
    required this.currentViewMode,
    required this.onViewModeChanged,
    super.key,
  });

  final ContactViewMode currentViewMode;
  final ValueChanged<ContactViewMode> onViewModeChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ContactViewMode.values.map((ContactViewMode mode) {
          final bool isSelected = mode == currentViewMode;
          return _buildModeButton(
            context,
            mode,
            isSelected,
            () => onViewModeChanged(mode),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    ContactViewMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final ThemeData theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _getIconForMode(mode),
              size: 20,
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 8),
            Text(
              mode.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForMode(ContactViewMode mode) {
    switch (mode) {
      case ContactViewMode.list:
        return Icons.list;
      case ContactViewMode.grid:
        return Icons.grid_view;
      case ContactViewMode.card:
        return Icons.view_agenda;
    }
  }
}
