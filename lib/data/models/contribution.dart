import 'package:uuid/uuid.dart';

enum ContributionStatus { pending, paid, missed }

class Contribution {
  final String id;
  final String groupId;
  final String contributorUserId;
  final String collectionScheduleId;
  final double amount;
  final DateTime contributionDate;
  final ContributionStatus status;

  Contribution({
    String? id,
    required this.groupId,
    required this.contributorUserId,
    required this.collectionScheduleId,
    required this.amount,
    DateTime? contributionDate,
    this.status = ContributionStatus.pending,
  })  : id = id ?? const Uuid().v4(),
        contributionDate = contributionDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'contributor_user_id': contributorUserId,
      'collection_schedule_id': collectionScheduleId,
      'amount': amount,
      'contribution_date': contributionDate.millisecondsSinceEpoch,
      'status': status.toString().split('.').last,
    };
  }

  factory Contribution.fromMap(Map<String, dynamic> map) {
    return Contribution(
      id: map['id'],
      groupId: map['group_id'],
      contributorUserId: map['contributor_user_id'],
      collectionScheduleId: map['collection_schedule_id'],
      amount: map['amount'].toDouble(),
      contributionDate: DateTime.fromMillisecondsSinceEpoch(map['contribution_date']),
      status: ContributionStatus.values.firstWhere((e) => e.toString().split('.').last == map['status']),
    );
  }

  Contribution copyWith({
    double? amount,
    DateTime? contributionDate,
    ContributionStatus? status,
  }) {
    return Contribution(
      id: id,
      groupId: groupId,
      contributorUserId: contributorUserId,
      collectionScheduleId: collectionScheduleId,
      amount: amount ?? this.amount,
      contributionDate: contributionDate ?? this.contributionDate,
      status: status ?? this.status,
    );
  }
}