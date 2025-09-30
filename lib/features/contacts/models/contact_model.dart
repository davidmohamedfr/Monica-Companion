import 'package:equatable/equatable.dart';

class Contact extends Equatable {
  const Contact({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.photoUrl,
    this.isFavorite = false,
    this.lastContactedAt,
    this.needsInteractionSoon = false,
  });

  final String id;
  final String name;
  final String? phone;
  final String? email;
  final String? photoUrl;
  final bool isFavorite;
  final DateTime? lastContactedAt;
  final bool needsInteractionSoon;

  Contact copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? photoUrl,
    bool? isFavorite,
    DateTime? lastContactedAt,
    bool? needsInteractionSoon,
  }) => Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      lastContactedAt: lastContactedAt ?? this.lastContactedAt,
      needsInteractionSoon: needsInteractionSoon ?? this.needsInteractionSoon,
    );

  @override
  List<Object?> get props => <Object?>[
        id,
        name,
        phone,
        email,
        photoUrl,
        isFavorite,
        lastContactedAt,
        needsInteractionSoon,
      ];
}
