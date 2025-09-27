import 'package:monica_companion/db/models/base_model.dart';

/// Debt entity representing financial interactions
enum DebtType {
  owedToMe('owed_to_me'),
  iOwe('i_owe');

  const DebtType(this.value);
  final String value;

  static DebtType fromString(String value) => DebtType.values.firstWhere(
    (DebtType type) => type.value == value,
    orElse: () => DebtType.owedToMe,
  );
}

class Debt extends BaseModel {
  const Debt({
    required this.contactId,
    required this.amount,
    required this.type,
    required this.date,
    super.id,
    super.createdAt,
    this.currency = 'USD',
    this.description,
    this.paid = false,
  });

  /// ID of the contact involved in this debt
  final int contactId;

  /// Amount of the debt
  final double amount;

  /// Currency code (ISO 4217)
  final String currency;

  /// Type of debt
  final DebtType type;

  /// Date of the debt (ISO 8601 string)
  final String date;

  /// Description of the debt
  final String? description;

  /// Whether the debt has been paid
  final bool paid;

  @override
  Map<String, dynamic> toMap() => <String, dynamic>{
    'id': id,
    'contact_id': contactId,
    'amount': amount,
    'currency': currency,
    'type': type.value,
    'date': date,
    'description': description,
    'paid': paid ? 1 : 0,
    'created_at': createdAt?.toIso8601String(),
  };

  /// Create Debt from database map
  static Debt fromMap(Map<String, dynamic> map) => Debt(
    id: map['id'] as int?,
    contactId: map['contact_id'] as int,
    amount: map['amount'] as double,
    currency: map['currency'] as String? ?? 'USD',
    type: DebtType.fromString(map['type'] as String),
    date: map['date'] as String,
    description: map['description'] as String?,
    paid: (map['paid'] as int?) == 1,
    createdAt: map['created_at'] != null
        ? DateTime.parse(map['created_at'] as String)
        : null,
  );

  @override
  Debt copyWith({
    int? id,
    DateTime? createdAt,
    int? contactId,
    double? amount,
    String? currency,
    DebtType? type,
    String? date,
    String? description,
    bool? paid,
  }) => Debt(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    contactId: contactId ?? this.contactId,
    amount: amount ?? this.amount,
    currency: currency ?? this.currency,
    type: type ?? this.type,
    date: date ?? this.date,
    description: description ?? this.description,
    paid: paid ?? this.paid,
  );

  @override
  List<Object?> get props => <Object?>[
    id,
    createdAt,
    contactId,
    amount,
    currency,
    type,
    date,
    description,
    paid,
  ];
}
