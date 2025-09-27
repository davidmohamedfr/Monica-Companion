import 'package:monica_companion/db/interfaces/database_interface.dart';
import 'package:monica_companion/db/migrations/migration_runner.dart';

/// Initial schema migration for Monica PRM database
class V1InitialSchema implements Migration {
  @override
  int get version => 1;

  @override
  List<String> get upStatements => <String>[
    // Schema version tracking table
    '''
        CREATE TABLE schema_version (
          version INTEGER PRIMARY KEY,
          migrated_at TEXT NOT NULL
        )
        ''',

    // Contacts table
    '''
        CREATE TABLE contacts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT,
          phone TEXT,
          avatar TEXT,
          birthday TEXT,
          address TEXT,
          notes TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''',

    // Interactions table
    '''
        CREATE TABLE interactions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          type TEXT NOT NULL,
          date TEXT NOT NULL,
          duration INTEGER,
          notes TEXT,
          location TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Life Events table
    '''
        CREATE TABLE life_events (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          event_type TEXT NOT NULL,
          date TEXT NOT NULL,
          description TEXT,
          importance INTEGER DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Notes table
    '''
        CREATE TABLE notes (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          content TEXT NOT NULL,
          category TEXT,
          is_private INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          updated_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Tasks table
    '''
        CREATE TABLE tasks (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT,
          completed INTEGER DEFAULT 0,
          priority INTEGER DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Gifts table
    '''
        CREATE TABLE gifts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          name TEXT NOT NULL,
          description TEXT,
          date_given TEXT,
          occasion TEXT,
          value REAL,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Activities table
    '''
        CREATE TABLE activities (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT,
          date TEXT NOT NULL,
          location TEXT,
          participants TEXT, -- JSON array of participant names
          created_at TEXT DEFAULT CURRENT_TIMESTAMP
        )
        ''',

    // Activity participants junction table
    '''
        CREATE TABLE activity_participants (
          activity_id INTEGER NOT NULL,
          contact_id INTEGER NOT NULL,
          PRIMARY KEY (activity_id, contact_id),
          FOREIGN KEY (activity_id) REFERENCES activities(id) ON DELETE CASCADE,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Debts table
    '''
        CREATE TABLE debts (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          amount REAL NOT NULL,
          currency TEXT DEFAULT 'USD',
          type TEXT NOT NULL, -- 'owed_to_me' or 'i_owe'
          date TEXT NOT NULL,
          description TEXT,
          paid INTEGER DEFAULT 0,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Reminders table
    '''
        CREATE TABLE reminders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          due_date TEXT NOT NULL,
          frequency TEXT, -- 'once', 'daily', 'weekly', 'monthly', 'yearly'
          active INTEGER DEFAULT 1,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Relationships table
    '''
        CREATE TABLE relationships (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          contact_id INTEGER NOT NULL,
          relationship_type TEXT NOT NULL,
          start_date TEXT,
          description TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY (contact_id) REFERENCES contacts(id) ON DELETE CASCADE
        )
        ''',

    // Indexes for performance
    'CREATE INDEX idx_contacts_name ON contacts(name)',
    'CREATE INDEX idx_contacts_email ON contacts(email)',
    'CREATE INDEX idx_interactions_contact_id ON interactions(contact_id)',
    'CREATE INDEX idx_interactions_date ON interactions(date)',
    'CREATE INDEX idx_life_events_contact_id ON life_events(contact_id)',
    'CREATE INDEX idx_notes_contact_id ON notes(contact_id)',
    'CREATE INDEX idx_tasks_contact_id ON tasks(contact_id)',
    'CREATE INDEX idx_tasks_due_date ON tasks(due_date)',
    'CREATE INDEX idx_gifts_contact_id ON gifts(contact_id)',
    'CREATE INDEX idx_activities_date ON activities(date)',
    'CREATE INDEX idx_debts_contact_id ON debts(contact_id)',
    'CREATE INDEX idx_reminders_contact_id ON reminders(contact_id)',
    'CREATE INDEX idx_reminders_due_date ON reminders(due_date)',
    'CREATE INDEX idx_relationships_contact_id ON relationships(contact_id)',

    // Triggers for updated_at columns
    '''
        CREATE TRIGGER update_contacts_updated_at
        AFTER UPDATE ON contacts
        FOR EACH ROW
        BEGIN
          UPDATE contacts SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
        END
        ''',

    '''
        CREATE TRIGGER update_notes_updated_at
        AFTER UPDATE ON notes
        FOR EACH ROW
        BEGIN
          UPDATE notes SET updated_at = CURRENT_TIMESTAMP WHERE id = NEW.id;
        END
        ''',
  ];

  @override
  List<String> get downStatements => <String>[
    'DROP TRIGGER IF EXISTS update_notes_updated_at',
    'DROP TRIGGER IF EXISTS update_contacts_updated_at',
    'DROP INDEX IF EXISTS idx_relationships_contact_id',
    'DROP INDEX IF EXISTS idx_reminders_due_date',
    'DROP INDEX IF EXISTS idx_reminders_contact_id',
    'DROP INDEX IF EXISTS idx_debts_contact_id',
    'DROP INDEX IF EXISTS idx_activities_date',
    'DROP INDEX IF EXISTS idx_gifts_contact_id',
    'DROP INDEX IF EXISTS idx_tasks_due_date',
    'DROP INDEX IF EXISTS idx_tasks_contact_id',
    'DROP INDEX IF EXISTS idx_notes_contact_id',
    'DROP INDEX IF EXISTS idx_life_events_contact_id',
    'DROP INDEX IF EXISTS idx_interactions_date',
    'DROP INDEX IF EXISTS idx_interactions_contact_id',
    'DROP INDEX IF EXISTS idx_contacts_email',
    'DROP INDEX IF EXISTS idx_contacts_name',
    'DROP TABLE IF EXISTS relationships',
    'DROP TABLE IF EXISTS reminders',
    'DROP TABLE IF EXISTS debts',
    'DROP TABLE IF EXISTS activity_participants',
    'DROP TABLE IF EXISTS activities',
    'DROP TABLE IF EXISTS gifts',
    'DROP TABLE IF EXISTS tasks',
    'DROP TABLE IF EXISTS notes',
    'DROP TABLE IF EXISTS life_events',
    'DROP TABLE IF EXISTS interactions',
    'DROP TABLE IF EXISTS contacts',
    'DROP TABLE IF EXISTS schema_version',
  ];

  @override
  Future<void> onUp(DatabaseInterface database) async {
    // Insert initial schema version
    await database.rawExecute(
      'INSERT INTO schema_version (version, migrated_at) VALUES (?, ?)',
      <dynamic>[version, DateTime.now().toIso8601String()],
    );
  }

  @override
  Future<void> onDown(DatabaseInterface database) async {
    // No special cleanup needed for rollback
  }
}
