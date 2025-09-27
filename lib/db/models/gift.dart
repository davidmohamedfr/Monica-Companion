import 'package:monica_companion/db/models/base_model.dart';

/// Gift entity representing presents given or received
class Gift extends BaseModel {
  const Gift({
    required this.contactId, required this.name, super.id,
    super.createdAt,
    this.description,
    this.dateGiven,
    this.occasion,
    this.value,
  });

  /// ID of the contact this gift is for/from
  final int contactId;

  /// Name of the gift
  final String name;

  /// Description of the gift
  final String? description;

  /// Date the gift was given (ISO 8601 string)
  final String? dateGiven;

  /// Occasion for the gift (birthday, christmas, etc.)
  final String? occasion;

  /// Monetary value of the gift
  final double? value;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'contact_id': contactId,
      'name': name,
      'description': description,
      'date_given': dateGiven,
      'occasion': occasion,
      'value': value,
      'created_at': createdAt?.toIso8601String(),
    };

  /// Create Gift from database map
  static Gift fromMap(Map<String, dynamic> map) => Gift(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int,
      name: map['name'] as String,
      description: map['description'] as String?,
      dateGiven: map['date_given'] as String?,
      occasion: map['occasion'] as String?,
      value: map['value'] as double?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );

  @override
  Gift copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    String? name,
    String? description,
    String? dateGiven,
    String? occasion,
    double? value,
  }) => Gift(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      contactId: contactId ?? this.contactId,
      name: name ?? this.name,
      description: description ?? this.description,
      dateGiven: dateGiven ?? this.dateGiven,
      occasion: occasion ?? this.occasion,
      value: value ?? this.value,
    );

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        contactId,
        name,
        description,
        dateGiven,
        occasion,
        value,
      ];
}
