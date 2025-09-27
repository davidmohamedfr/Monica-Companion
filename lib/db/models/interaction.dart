import 'package:monica_companion/db/models/base_model.dart';

/// Interaction entity representing communication records
class Interaction extends BaseModel {
  const Interaction({
    required this.contactId, required this.type, required this.date, super.id,
    super.createdAt,
    this.duration,
    this.notes,
    this.location,
  });

  /// ID of the contact this interaction is with
  final int contactId;

  /// Type of interaction (call, message, meeting, etc.)
  final String type;

  /// Date and time of the interaction (ISO 8601 string)
  final String date;

  /// Duration in seconds (for calls, meetings, etc.)
  final int? duration;

  /// Notes about the interaction
  final String? notes;

  /// Location where the interaction occurred
  final String? location;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'contact_id': contactId,
      'type': type,
      'date': date,
      'duration': duration,
      'notes': notes,
      'location': location,
      'created_at': createdAt?.toIso8601String(),
    };

  /// Create Interaction from database map
  static Interaction fromMap(Map<String, dynamic> map) => Interaction(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int,
      type: map['type'] as String,
      date: map['date'] as String,
      duration: map['duration'] as int?,
      notes: map['notes'] as String?,
      location: map['location'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );

  @override
  Interaction copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    String? type,
    String? date,
    int? duration,
    String? notes,
    String? location,
  }) => Interaction(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contactId: contactId ?? this.contactId,
      type: type ?? this.type,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      notes: notes ?? this.notes,
      location: location ?? this.location,
    );

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        contactId,
        type,
        date,
        duration,
        notes,
        location,
      ];
}
