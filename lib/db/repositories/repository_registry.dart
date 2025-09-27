import 'package:monica_companion/db/interfaces/activity_repository.dart';
import 'package:monica_companion/db/interfaces/contact_repository.dart';
import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/interfaces/debt_repository.dart';
import 'package:monica_companion/db/interfaces/gift_repository.dart';
import 'package:monica_companion/db/interfaces/interaction_repository.dart';
import 'package:monica_companion/db/interfaces/life_event_repository.dart';
import 'package:monica_companion/db/interfaces/note_repository.dart';
import 'package:monica_companion/db/interfaces/relationship_repository.dart';
import 'package:monica_companion/db/interfaces/reminder_repository.dart';
import 'package:monica_companion/db/interfaces/task_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_activity_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_contact_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_debt_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_gift_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_interaction_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_life_event_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_note_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_relationship_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_reminder_repository.dart';
import 'package:monica_companion/db/repositories/sqlite_task_repository.dart';

/// Registry for managing repository instances and dependency injection
class RepositoryRegistry {
  RepositoryRegistry(this._database);

  final DatabaseInterface _database;

  ContactRepository? _contactRepository;
  InteractionRepository? _interactionRepository;
  LifeEventRepository? _lifeEventRepository;
  NoteRepository? _noteRepository;
  TaskRepository? _taskRepository;
  GiftRepository? _giftRepository;
  ActivityRepository? _activityRepository;
  DebtRepository? _debtRepository;
  ReminderRepository? _reminderRepository;
  RelationshipRepository? _relationshipRepository;

  /// Get the contact repository instance
  ContactRepository get contactRepository {
    _contactRepository ??= SqliteContactRepository(_database);
    return _contactRepository!;
  }

  /// Get the interaction repository instance
  InteractionRepository get interactionRepository {
    _interactionRepository ??= SqliteInteractionRepository(_database);
    return _interactionRepository!;
  }

  /// Get the life event repository instance
  LifeEventRepository get lifeEventRepository {
    _lifeEventRepository ??= SqliteLifeEventRepository(_database);
    return _lifeEventRepository!;
  }

  /// Get the note repository instance
  NoteRepository get noteRepository {
    _noteRepository ??= SqliteNoteRepository(_database);
    return _noteRepository!;
  }

  /// Get the task repository instance
  TaskRepository get taskRepository {
    _taskRepository ??= SqliteTaskRepository(_database);
    return _taskRepository!;
  }

  /// Get the gift repository instance
  GiftRepository get giftRepository {
    _giftRepository ??= SqliteGiftRepository(_database);
    return _giftRepository!;
  }

  /// Get the activity repository instance
  ActivityRepository get activityRepository {
    _activityRepository ??= SqliteActivityRepository(_database);
    return _activityRepository!;
  }

  /// Get the debt repository instance
  DebtRepository get debtRepository {
    _debtRepository ??= SqliteDebtRepository(_database);
    return _debtRepository!;
  }

  /// Get the reminder repository instance
  ReminderRepository get reminderRepository {
    _reminderRepository ??= SqliteReminderRepository(_database);
    return _reminderRepository!;
  }

  /// Get the relationship repository instance
  RelationshipRepository get relationshipRepository {
    _relationshipRepository ??= SqliteRelationshipRepository(_database);
    return _relationshipRepository!;
  }

  /// Initialize all repositories
  Future<void> initialize() async {
    // Database is already initialized by DatabaseModule
    // This method can be used for any setup that needs to happen after database init
  }

  /// Dispose of all repository instances
  void dispose() {
    _contactRepository = null;
    _interactionRepository = null;
    _lifeEventRepository = null;
    _noteRepository = null;
    _taskRepository = null;
    _giftRepository = null;
    _activityRepository = null;
    _debtRepository = null;
    _reminderRepository = null;
    _relationshipRepository = null;
  }
}
