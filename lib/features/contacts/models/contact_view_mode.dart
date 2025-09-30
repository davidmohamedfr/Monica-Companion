enum ContactViewMode {
  list,
  grid,
  card;

  String get displayName {
    switch (this) {
      case ContactViewMode.list:
        return 'List';
      case ContactViewMode.grid:
        return 'Grid';
      case ContactViewMode.card:
        return 'Card';
    }
  }
}
