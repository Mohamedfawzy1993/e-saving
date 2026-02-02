import 'package:uuid/uuid.dart';
import '../../core/utils/crypto_utils.dart';

enum CycleType { weekly, monthly, custom }

class Group {
  final String id;
  final String name;
  final String? description;
  final String adminId;
  final CycleType cycleType;
  final int cycleDuration;
  final DateTime startDate;
  final DateTime? endDate;
  final String inviteCode;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Group({
    String? id,
    required this.name,
    this.description,
    required this.adminId,
    required this.cycleType,
    required this.cycleDuration,
    required this.startDate,
    this.endDate,
    String? inviteCode,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        inviteCode = inviteCode ?? CryptoUtils.generateInviteCode(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'admin_id': adminId,
      'cycle_type': cycleType.toString().split('.').last,
      'cycle_duration': cycleDuration,
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'invite_code': inviteCode,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      adminId: map['admin_id'],
      cycleType: CycleType.values.firstWhere((e) => e.toString().split('.').last == map['cycle_type']),
      cycleDuration: map['cycle_duration'],
      startDate: DateTime.fromMillisecondsSinceEpoch(map['start_date']),
      endDate: map['end_date'] != null ? DateTime.fromMillisecondsSinceEpoch(map['end_date']) : null,
      inviteCode: map['invite_code'],
      isActive: map['is_active'] == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at']),
    );
  }

  Group copyWith({
    String? name,
    String? description,
    CycleType? cycleType,
    int? cycleDuration,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return Group(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      adminId: adminId,
      cycleType: cycleType ?? this.cycleType,
      cycleDuration: cycleDuration ?? this.cycleDuration,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      inviteCode: inviteCode,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}