import 'package:monica_companion/db/models/base_model.dart';

/// Note entity representing private observations about contacts
class Note extends BaseModel {
  const Note({
    required this.contactId, required this.content, super.id,
    super.createdAt,
    super.updatedAt,
    this.category,
    this.isPrivate = false,
  });

  /// ID of the contact this note is about
  final int contactId;

  /// Content of the note
  final String content;

  /// Category for organizing notes
  final String? category;

  /// Whether this note is private
  final bool isPrivate;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
      'id': id,
      'contact_id': contactId,
      'content': content,
      'category': category,
      'is_private': isPrivate ? 1 : 0,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };

  /// Create Note from database map
  static Note fromMap(Map<String, dynamic> map) => Note(
      id: map['id'] as int?,
      contactId: map['contact_id'] as int,
      content: map['content'] as String,
      category: map['category'] as String?,
      isPrivate: (map['is_private'] as int?) == 1,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );

  @override
  Note copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? contactId,
    String? content,
    String? category,
    bool? isPrivate,
  }) => Note(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      contactId: contactId ?? this.contactId,
      content: content ?? this.content,
      category: category ?? this.category,
      isPrivate: isPrivate ?? this.isPrivate,
    );

  @override
  List<Object?> get props => <Object?>[
        id,
        createdAt,
        updatedAt,
        contactId,
        content,
        category,
        isPrivate,
      ];
}
