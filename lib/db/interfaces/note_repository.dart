import 'package:monica_companion/db/interfaces/repository_interface.dart';
import 'package:monica_companion/db/models/note.dart';

/// Repository interface for Note entities
abstract class NoteRepository implements RepositoryInterface<Note, int> {
  /// Find notes for a specific contact
  Future<List<Note>> findByContactId(int contactId);

  /// Find notes by category
  Future<List<Note>> findByCategory(String category);

  /// Find private notes only
  Future<List<Note>> findPrivate();

  /// Find public notes only
  Future<List<Note>> findPublic();

  /// Search notes by content
  Future<List<Note>> findByContent(String searchQuery);

  /// Find recent notes (last N days)
  Future<List<Note>> findRecent(int days);

  /// Find notes updated within a date range
  Future<List<Note>> findByDateRange(DateTime start, DateTime end);

  /// Count notes for a contact
  Future<int> countByContactId(int contactId);

  /// Get the most recent note for a contact
  Future<Note?> findMostRecentByContactId(int contactId);
}
