import 'package:monica_companion/db/models/base_model.dart';

/// Relationship entity representing connection definitions
class Relationship extends BaseModel {
  const Relationship({
    required this.contactId,
    required this.relationshipType,
    super.id,
    super.createdAt,
    this.startDate,
    this.description,
  });

  /// ID of the contact this relationship is with
  final int contactId;

  /// Type of relationship (family, friend, colleague, etc.)
  final String relationshipType;

  /// When this relationship started (ISO 8601 string)
  final String? startDate;

  /// Description of the relationship
  final String? description;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'contact_id': contactId,
    'relationship_type': relationshipType,
    'start_date': startDate,
    'description': description,
    'created_at': createdAt?.toIso8601String(),
  };

  /// Create Relationship from database map
  static Relationship fromMap(Map<String, dynamic> map) => Relationship(
    id: map['id'] as int?,
    contactId: map['contact_id'] as int,
    relationshipType: map['relationship_type'] as String,
    startDate: map['start_date'] as String?,
    description: map['description'] as String?,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
  );

  @override
  Relationship copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    String? relationshipType,
    String? startDate,
    String? description,
  }) => Relationship(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    contactId: contactId ?? this.contactId,
    relationshipType: relationshipType ?? this.relationshipType,
    startDate: startDate ?? this.startDate,
    description: description ?? this.description,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    createdAt,
    contactId,
    relationshipType,
    startDate,
    description,
  ];
}
