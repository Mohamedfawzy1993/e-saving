import 'package:uuid/uuid.dart';

enum CollectionStatus { pending, completed, skipped }

class CollectionSchedule {
  final String id;
  final String groupId;
  final String collectorUserId;
  final DateTime collectionDate;
  final int cycleNumber;
  final CollectionStatus status;
  final double? totalAmount;
  final DateTime createdAt;

  CollectionSchedule({
    String? id,
    required this.groupId,
    required this.collectorUserId,
    required this.collectionDate,
    required this.cycleNumber,
    this.status = CollectionStatus.pending,
    this.totalAmount,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'collector_user_id': collectorUserId,
      'collection_date': collectionDate.millisecondsSinceEpoch,
      'cycle_number': cycleNumber,
      'status': status.toString().split('.').last,
      'total_amount': totalAmount,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }

  factory CollectionSchedule.fromMap(Map<String, dynamic> map) {
    return CollectionSchedule(
      id: map['id'],
      groupId: map['group_id'],
      collectorUserId: map['collector_user_id'],
      collectionDate: DateTime.fromMillisecondsSinceEpoch(map['collection_date']),
      cycleNumber: map['cycle_number'],
      status: CollectionStatus.values.firstWhere((e) => e.toString().split('.').last == map['status']),
      totalAmount: map['total_amount']?.toDouble(),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at']),
    );
  }

  CollectionSchedule copyWith({
    CollectionStatus? status,
    double? totalAmount,
  }) {
    return CollectionSchedule(
      id: id,
      groupId: groupId,
      collectorUserId: collectorUserId,
      collectionDate: collectionDate,
      cycleNumber: cycleNumber,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt,
    );
  }
}