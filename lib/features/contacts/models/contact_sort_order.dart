/// Enum for contact sorting options
enum ContactSortOrder {
  nameAscending,
  nameDescending,
  lastInteractionRecent,
  lastInteractionOldest;

  /// Human-readable display name for the sort order
  String get displayName {
    switch (this) {
      case ContactSortOrder.nameAscending:
        return 'Name (A-Z)';
      case ContactSortOrder.nameDescending:
        return 'Name (Z-A)';
      case ContactSortOrder.lastInteractionRecent:
        return 'Last interaction (Recent)';
      case ContactSortOrder.lastInteractionOldest:
        return 'Last interaction (Oldest)';
    }
  }
}
