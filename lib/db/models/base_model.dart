import 'package:equatable/equatable.dart';

/// Base model class for all database entities
abstract class BaseModel extends Equatable {
  const BaseModel({this.id, this.createdAt, this.updatedAt});

  /// Primary key
  final int? id;

  /// Created timestamp
  final DateTime? createdAt;

  /// Updated timestamp
  final DateTime? updatedAt;

  /// Convert model to Map for database storage
  Map<String, dynamic> toMap();

  /// Create model instance from database Map
  static BaseModel fromMap(Map<String, dynamic> map) {
    throw UnimplementedError('fromMap must be implemented by subclass');
  }

  /// Copy model with updated fields
  BaseModel copyWith();

  @override
  List<Object?> get props => <Object?>[id, createdAt, updatedAt];
}
