import '../database/database_helper.dart';
import '../models/group.dart';
import '../models/group_member.dart';
import '../models/collection_schedule.dart';
import '../../core/utils/date_utils.dart' as date_utils;

class GroupRepository {
  final DatabaseHelper _db = DatabaseHelper();

  // Group CRUD operations
  Future<Group> createGroup(Group group) async {
    await _db.insert('groups', group.toMap());
    return group;
  }

  Future<List<Group>> getUserGroups(String userId) async {
    final result = await _db.rawQuery('''
      SELECT g.* FROM groups g
      INNER JOIN group_members gm ON g.id = gm.group_id
      WHERE gm.user_id = ? AND gm.is_active = 1 AND g.is_active = 1
      ORDER BY g.created_at DESC
    ''', [userId]);
    return result.map((map) => Group.fromMap(map)).toList();
  }

  Future<Group?> getGroupById(String groupId) async {
    final result = await _db.query(
      'groups',
      where: 'id = ?',
      whereArgs: [groupId],
    );
    if (result.isEmpty) return null;
    return Group.fromMap(result.first);
  }

  Future<Group?> getGroupByInviteCode(String inviteCode) async {
    final result = await _db.query(
      'groups',
      where: 'invite_code = ? AND is_active = 1',
      whereArgs: [inviteCode],
    );
    if (result.isEmpty) return null;
    return Group.fromMap(result.first);
  }

  Future<void> updateGroup(Group group) async {
    await _db.update(
      'groups',
      group.toMap(),
      where: 'id = ?',
      whereArgs: [group.id],
    );
  }

  Future<void> deactivateGroup(String groupId) async {
    await _db.update(
      'groups',
      {'is_active': 0, 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: [groupId],
    );
  }

  // Group Member operations
  Future<GroupMember> addMemberToGroup(GroupMember member) async {
    await _db.insert('group_members', member.toMap());
    return member;
  }

  Future<List<GroupMember>> getGroupMembers(String groupId) async {
    final result = await _db.query(
      'group_members',
      where: 'group_id = ? AND is_active = 1',
      whereArgs: [groupId],
      orderBy: 'join_date ASC',
    );
    return result.map((map) => GroupMember.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getGroupMembersWithUserDetails(String groupId) async {
    final result = await _db.rawQuery('''
      SELECT 
        gm.*,
        u.username,
        u.full_name
      FROM group_members gm
      JOIN users u ON gm.user_id = u.id
      WHERE gm.group_id = ? AND gm.is_active = 1
      ORDER BY gm.join_date ASC
    ''', [groupId]);
    return result;
  }

  Future<bool> isUserInGroup(String userId, String groupId) async {
    final result = await _db.query(
      'group_members',
      where: 'user_id = ? AND group_id = ? AND is_active = 1',
      whereArgs: [userId, groupId],
    );
    return result.isNotEmpty;
  }

  Future<bool> isUserGroupAdmin(String userId, String groupId) async {
    final result = await _db.query(
      'groups',
      where: 'id = ? AND admin_id = ?',
      whereArgs: [groupId, userId],
    );
    return result.isNotEmpty;
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    await _db.update(
      'group_members',
      {'is_active': 0},
      where: 'group_id = ? AND user_id = ?',
      whereArgs: [groupId, userId],
    );
  }

  // Collection Schedule operations
  Future<void> generateCollectionSchedule(String groupId) async {
    final group = await getGroupById(groupId);
    if (group == null) return;

    final members = await getGroupMembers(groupId);
    if (members.isEmpty) return;

    // Clear existing schedule
    await _db.delete('collection_schedule', where: 'group_id = ?', whereArgs: [groupId]);

    DateTime currentDate = group.startDate;
    
    // Calculate cycle duration in days
    int cycleDays;
    switch (group.cycleType) {
      case CycleType.weekly:
        cycleDays = 7;
        break;
      case CycleType.monthly:
        cycleDays = 30;
        break;
      case CycleType.custom:
        cycleDays = group.cycleDuration;
        break;
    }

    // Generate schedule for each member
    for (int i = 0; i < members.length; i++) {
      final member = members[i];
      final collectionDate = currentDate.add(Duration(days: cycleDays * i));
      
      // Stop if we've reached the end date
      if (group.endDate != null && collectionDate.isAfter(group.endDate!)) {
        break;
      }

      final schedule = CollectionSchedule(
        groupId: groupId,
        collectorUserId: member.userId,
        collectionDate: collectionDate,
        cycleNumber: i + 1,
      );

      await _db.insert('collection_schedule', schedule.toMap());
    }
  }

  Future<List<CollectionSchedule>> getGroupCollectionSchedule(String groupId) async {
    final result = await _db.query(
      'collection_schedule',
      where: 'group_id = ?',
      whereArgs: [groupId],
      orderBy: 'collection_date ASC',
    );
    return result.map((map) => CollectionSchedule.fromMap(map)).toList();
  }

  Future<List<Map<String, dynamic>>> getGroupCollectionScheduleWithUserDetails(String groupId) async {
    final result = await _db.rawQuery('''
      SELECT 
        cs.*,
        u.username,
        u.full_name
      FROM collection_schedule cs
      JOIN users u ON cs.collector_user_id = u.id
      WHERE cs.group_id = ?
      ORDER BY cs.collection_date ASC
    ''', [groupId]);
    return result;
  }

  Future<CollectionSchedule?> getNextUserCollection(String userId) async {
    final result = await _db.query(
      'collection_schedule',
      where: 'collector_user_id = ? AND status = ? AND collection_date > ?',
      whereArgs: [userId, CollectionStatus.pending.toString().split('.').last, DateTime.now().millisecondsSinceEpoch],
      orderBy: 'collection_date ASC',
      limit: 1,
    );
    if (result.isEmpty) return null;
    return CollectionSchedule.fromMap(result.first);
  }

  Future<List<CollectionSchedule>> getUserUpcomingCollections(String userId) async {
    final result = await _db.query(
      'collection_schedule',
      where: 'collector_user_id = ? AND status = ? AND collection_date > ?',
      whereArgs: [userId, CollectionStatus.pending.toString().split('.').last, DateTime.now().millisecondsSinceEpoch],
      orderBy: 'collection_date ASC',
    );
    return result.map((map) => CollectionSchedule.fromMap(map)).toList();
  }

  Future<void> updateCollectionSchedule(CollectionSchedule schedule) async {
    await _db.update(
      'collection_schedule',
      schedule.toMap(),
      where: 'id = ?',
      whereArgs: [schedule.id],
    );
  }

  // Statistics
  Future<int> getGroupMemberCount(String groupId) async {
    final result = await _db.query(
      'group_members',
      where: 'group_id = ? AND is_active = 1',
      whereArgs: [groupId],
    );
    return result.length;
  }

  Future<double> getGroupTotalContributions(String groupId) async {
    final result = await _db.rawQuery('''
      SELECT SUM(contribution_amount) as total
      FROM group_members
      WHERE group_id = ? AND is_active = 1
    ''', [groupId]);
    
    if (result.isEmpty || result.first['total'] == null) return 0.0;
    return (result.first['total'] as num).toDouble();
  }

  Future<double> getUserCollectionAmount(String groupId, String userId) async {
    // Get total contributions from all active members
    return await getGroupTotalContributions(groupId);
  }

  Future<Map<String, dynamic>> getUserCollectionInfo(String groupId, String userId) async {
    try {
      // Get user's contribution amount
      final userMember = await _db.query(
        'group_members',
        where: 'group_id = ? AND user_id = ? AND is_active = 1',
        whereArgs: [groupId, userId],
      );
      
      if (userMember.isEmpty) {
        return {
          'user_contribution_amount': 0.0,
          'total_cycles': 0,
          'user_total_collection': 0.0,
          'has_collection_turn': false,
          'collection_date': null,
          'cycle_number': null,
        };
      }

      final userContribution = (userMember.first['contribution_amount'] as num?)?.toDouble() ?? 0.0;
      
      // Get total number of cycles (members)
      final totalMembers = await getGroupMemberCount(groupId);
      
      // User will collect their contribution amount × number of cycles
      final userTotalCollection = userContribution * totalMembers;
      
      // Get user's collection schedule
      final userSchedule = await _db.query(
        'collection_schedule',
        where: 'group_id = ? AND collector_user_id = ?',
        whereArgs: [groupId, userId],
        orderBy: 'collection_date ASC',
        limit: 1,
      );

      return {
        'user_contribution_amount': userContribution,
        'total_cycles': totalMembers,
        'user_total_collection': userTotalCollection,
        'has_collection_turn': userSchedule.isNotEmpty,
        'collection_date': userSchedule.isNotEmpty 
            ? DateTime.fromMillisecondsSinceEpoch(userSchedule.first['collection_date'] as int)
            : null,
        'cycle_number': userSchedule.isNotEmpty ? userSchedule.first['cycle_number'] as int? : null,
      };
    } catch (e) {
      // Return default values on error
      return {
        'user_contribution_amount': 0.0,
        'total_cycles': 0,
        'user_total_collection': 0.0,
        'has_collection_turn': false,
        'collection_date': null,
        'cycle_number': null,
      };
    }
  }
}