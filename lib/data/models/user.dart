import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String username;
  final String? email;
  final String fullName;
  final String pinHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    String? id,
    required this.username,
    this.email,
    required this.fullName,
    required this.pinHash,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'pin_hash': pinHash,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      email: map['email'],
      fullName: map['full_name'],
      pinHash: map['pin_hash'],
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  User copyWith({
    String? username,
    String? email,
    String? fullName,
    String? pinHash,
  }) {
    return User(
      id: id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      pinHash: pinHash ?? this.pinHash,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}