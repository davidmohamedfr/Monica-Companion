import 'package:monica_companion/db/models/base_model.dart';

/// Task entity representing relationship-related follow-ups
class Task extends BaseModel {
  const Task({
    required this.contactId,
    required this.title,
    super.id,
    super.createdAt,
    this.description,
    this.dueDate,
    this.completed = false,
    this.priority = 1,
  });

  /// ID of the contact this task is for
  final int contactId;

  /// Task title
  final String title;

  /// Task description
  final String? description;

  /// Due date (ISO 8601 string)
  final String? dueDate;

  /// Whether the task is completed
  final bool completed;

  /// Priority level (1-5, where 5 is highest priority)
  final int priority;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'contact_id': contactId,
    'title': title,
    'description': description,
    'due_date': dueDate,
    'completed': completed ? 1 : 0,
    'priority': priority,
    'created_at': createdAt?.toIso8601String(),
  };

  /// Create Task from database map
  static Task fromMap(Map<String, dynamic> map) => Task(
    id: map['id'] as int?,
    contactId: map['contact_id'] as int,
    title: map['title'] as String,
    description: map['description'] as String?,
    dueDate: map['due_date'] as String?,
    completed: (map['completed'] as int?) == 1,
    priority: map['priority'] as int? ?? 1,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
  );

  @override
  Task copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    String? title,
    String? description,
    String? dueDate,
    bool? completed,
    int? priority,
  }) => Task(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    contactId: contactId ?? this.contactId,
    title: title ?? this.title,
    description: description ?? this.description,
    dueDate: dueDate ?? this.dueDate,
    completed: completed ?? this.completed,
    priority: priority ?? this.priority,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    createdAt,
    contactId,
    title,
    description,
    dueDate,
    completed,
    priority,
  ];
}
