import 'package:monica_companion/db/models/base_model.dart';

/// Life Event entity representing important occasions
class LifeEvent extends BaseModel {
  const LifeEvent({
    required this.contactId, required this.eventType, required this.date, super.id,
    super.createdAt,
    this.description,
    this.importance = 1,
  });

  /// ID of the contact this life event is for
  final int contactId;

  /// Type of life event (birthday, anniversary, job change, etc.)
  final String eventType;

  /// Date of the life event (ISO 8601 string)
  final String date;

  /// Description of the life event
  final String? description;

  /// Importance level (1-5, where 5 is most important)
  final int importance;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'contact_id': contactId,
      'event_type': eventType,
      'date': date,
      'description': description,
      'importance': importance,
      'created_at': createdAt?.toIso8601String(),
    };

  /// Create LifeEvent from database map
  static LifeEvent fromMap(Map<String, dynamic> map) => LifeEvent(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int,
      eventType: map['event_type'] as String,
      date: map['date'] as String,
      description: map['description'] as String?,
      importance: map['importance'] as int? ?? 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );

  @override
  LifeEvent copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    String? eventType,
    String? date,
    String? description,
    int? importance,
  }) => LifeEvent(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contactId: contactId ?? this.contactId,
      eventType: eventType ?? this.eventType,
      date: date ?? this.date,
      description: description ?? this.description,
      importance: importance ?? this.importance,
    );

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        contactId,
        eventType,
        date,
        description,
        importance,
      ];
}
