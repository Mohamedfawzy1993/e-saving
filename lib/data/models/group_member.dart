import 'package:uuid/uuid.dart';

class GroupMember {
  final String id;
  final String groupId;
  final String userId;
  final double contributionAmount;
  final DateTime joinDate;
  final bool isActive;

  GroupMember({
    String? id,
    required this.groupId,
    required this.userId,
    required this.contributionAmount,
    DateTime? joinDate,
    this.isActive = true,
  })  : id = id ?? const Uuid().v4(),
        joinDate = joinDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'user_id': userId,
      'contribution_amount': contributionAmount,
      'join_date': joinDate.millisecondsSinceEpoch,
      'is_active': isActive ? 1 : 0,
    };
  }

  factory GroupMember.fromMap(Map<String, dynamic> map) {
    return GroupMember(
      id: map['id'],
      groupId: map['group_id'],
      userId: map['user_id'],
      contributionAmount: map['contribution_amount'].toDouble(),
      joinDate: DateTime.fromMillisecondsSinceEpoch(map['join_date']),
      isActive: map['is_active'] == 1,
    );
  }

  GroupMember copyWith({
    double? contributionAmount,
    bool? isActive,
  }) {
    return GroupMember(
      id: id,
      groupId: groupId,
      userId: userId,
      contributionAmount: contributionAmount ?? this.contributionAmount,
      joinDate: joinDate,
      isActive: isActive ?? this.isActive,
    );
  }
}