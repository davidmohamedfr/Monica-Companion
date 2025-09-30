enum ContactFilter {
  all,
  favorites,
  recentlyContacted,
  needsInteraction;

  String get displayName {
    switch (this) {
      case ContactFilter.all:
        return 'All';
      case ContactFilter.favorites:
        return 'Favorites';
      case ContactFilter.recentlyContacted:
        return 'Recently Contacted';
      case ContactFilter.needsInteraction:
        return 'Needs Interaction';
    }
  }

  String get description {
    switch (this) {
      case ContactFilter.all:
        return 'Show all contacts';
      case ContactFilter.favorites:
        return 'Show favorite contacts only';
      case ContactFilter.recentlyContacted:
        return 'Show recently contacted people';
      case ContactFilter.needsInteraction:
        return 'Show contacts needing interaction soon';
    }
  }
}
