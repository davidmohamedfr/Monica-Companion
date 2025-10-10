import 'package:monica_companion/db/models/base_model.dart';

/// Contact entity representing a person in the personal network
class Contact extends BaseModel {
  const Contact({
    required this.name,
    super.id,
    super.createdAt,
    super.updatedAt,
    this.email,
    this.phone,
    this.avatar,
    this.birthday,
    this.address,
    this.notes,
  });

  /// Contact's full name
  final String name;

  /// Contact's email address
  final String? email;

  /// Contact's phone number
  final String? phone;

  /// Path to contact's avatar image
  final String? avatar;

  /// Contact's birthday (ISO 8601 date string)
  final String? birthday;

  /// Contact's address
  final String? address;

  /// Additional notes about the contact
  final String? notes;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'birthday': birthday,
    'address': address,
    'notes': notes,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  /// Create Contact from database map
  static Contact fromMap(Map<String, dynamic> map) => Contact(
    id: map['id'] as int?,
    name: map['name'] as String,
    email: map['email'] as String?,
    phone: map['phone'] as String?,
    avatar: map['avatar'] as String?,
    birthday: map['birthday'] as String?,
    address: map['address'] as String?,
    notes: map['notes'] as String?,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
    updatedAt: map['updated_at'] != null
        ? DateTime.parse(map['updated_at'] as String)
        : null,
  );

  @override
  Contact copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? name,
    String? email,
    String? phone,
    String? avatar,
    String? birthday,
    String? address,
    String? notes,
  }) => Contact(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    name: name ?? this.name,
    email: email ?? this.email,
    phone: phone ?? this.phone,
    avatar: avatar ?? this.avatar,
    birthday: birthday ?? this.birthday,
    address: address ?? this.address,
    notes: notes ?? this.notes,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    createdAt,
    updatedAt,
    name,
    email,
    phone,
    avatar,
    birthday,
    address,
    notes,
  ];
}
