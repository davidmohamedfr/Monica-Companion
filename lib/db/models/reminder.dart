import 'package:monica_companion/db/models/base_model.dart';

/// Reminder entity representing automated notifications
enum ReminderFrequency {
  once('once'),
  daily('daily'),
  weekly('weekly'),
  monthly('monthly'),
  yearly('yearly');

  const ReminderFrequency(this.value);
  final String value;

  static ReminderFrequency fromString(String value) =>
      ReminderFrequency.values.firstWhere(
        (ReminderFrequency freq) => freq.value == value,
        orElse: () => ReminderFrequency.once,
      );
}

class Reminder extends BaseModel {
  const Reminder({
    required this.contactId,
    required this.title,
    required this.dueDate,
    super.id,
    super.createdAt,
    this.description,
    this.frequency,
    this.active = true,
  });

  /// ID of the contact this reminder is for
  final int contactId;

  /// Reminder title
  final String title;

  /// Reminder description
  final String? description;

  /// Due date for the reminder (ISO 8601 string)
  final String dueDate;

  /// How often this reminder repeats
  final ReminderFrequency? frequency;

  /// Whether this reminder is active
  final bool active;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'contact_id': contactId,
    'title': title,
    'description': description,
    'due_date': dueDate,
    'frequency': frequency?.value,
    'active': active ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
  };

  /// Create Reminder from database map
  static Reminder fromMap(Map<String, dynamic> map) => Reminder(
    id: map['id'] as int?,
    contactId: map['contact_id'] as int,
    title: map['title'] as String,
    description: map['description'] as String?,
    dueDate: map['due_date'] as String,
    frequency: map['frequency'] != null
        ? ReminderFrequency.fromString(map['frequency'] as String)
        : null,
    active: (map['active'] as int?) != 0, // Default to true if null
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
  );

  @override
  Reminder copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    String? title,
    String? description,
    String? dueDate,
    ReminderFrequency? frequency,
    bool? active,
  }) => Reminder(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    contactId: contactId ?? this.contactId,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    frequency: frequency ?? this.frequency,
    active: active ?? this.active,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    createdAt,
    contactId,
    title,
    description,
    dueDate,
    frequency,
    active,
  ];
}
