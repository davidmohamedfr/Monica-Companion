import 'package:monica_companion/db/models/base_model.dart';

/// Activity entity representing shared experiences or events
class Activity extends BaseModel {
  const Activity({
    required this.title,
    required this.date,
    super.id,
    super.createdAt,
    this.description,
    this.location,
    this.participants = const <int>[],
  });

  /// Activity title
  final String title;

  /// Activity description
  final String? description;

  /// Date of the activity (ISO 8601 string)
  final String date;

  /// Location of the activity
  final String? location;

  /// List of participant contact IDs
  final List<int> participants;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'title': title,
    'description': description,
    'date': date,
    'location': location,
    'participants': participants.join(','), // Store as comma-separated string
    'created_at': createdAt?.toIso8601String(),
  };

  /// Create Activity from database map
  static Activity fromMap(Map<String, dynamic> map) {
    final String? participantsString = map['participants'] as String?;
    final List<int> participants =
        participantsString != null && participantsString.isNotEmpty
        ? participantsString.split(',').map(int.parse).toList()
        : <int>[];

    return Activity(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String?,
      date: map['date'] as String,
      location: map['location'] as String?,
      participants: participants,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  @override
  Activity copyWith({
    int? id,
    DateTime? createdAt,
    String? title,
    String? description,
    String? date,
    String? location,
    List<int>? participants,
  }) => Activity(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    title: title ?? this.title,
    description: description ?? this.description,
    date: date ?? this.date,
    location: location ?? this.location,
    participants: participants ?? this.participants,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    createdAt,
    title,
    description,
    date,
    location,
    participants,
  ];
}
