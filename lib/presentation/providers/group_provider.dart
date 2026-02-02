import 'package:flutter/foundation.dart';
import '../../data/models/group.dart';
import '../../data/models/group_member.dart';
import '../../data/models/collection_schedule.dart';
import '../../data/repositories/group_repository.dart';

class GroupProvider extends ChangeNotifier {
  final GroupRepository _groupRepository = GroupRepository();
  
  List<Group> _userGroups = [];
  Group? _selectedGroup;
  List<Map<String, dynamic>> _groupMembers = [];
  List<Map<String, dynamic>> _collectionSchedule = [];
  CollectionSchedule? _nextCollection;
  Map<String, dynamic>? _userCollectionInfo;
  bool _isLoading = false;
  String? _error;

  List<Group> get userGroups => _userGroups;
  Group? get selectedGroup => _selectedGroup;
  List<Map<String, dynamic>> get groupMembers => _groupMembers;
  List<Map<String, dynamic>> get collectionSchedule => _collectionSchedule;
  CollectionSchedule? get nextCollection => _nextCollection;
  Map<String, dynamic>? get userCollectionInfo => _userCollectionInfo;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserGroups(String userId) async {
    _setLoading(true);
    try {
      _userGroups = await _groupRepository.getUserGroups(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createGroup({
    required String name,
    required String adminId,
    required CycleType cycleType,
    required int cycleDuration,
    required DateTime startDate,
    required double contributionAmount,
    String? description,
    DateTime? endDate,
  }) async {
    _setLoading(true);
    try {
      final group = Group(
        name: name,
        description: description,
        adminId: adminId,
        cycleType: cycleType,
        cycleDuration: cycleDuration,
        startDate: startDate,
        endDate: endDate,
      );

      await _groupRepository.createGroup(group);

      // Add admin as first member
      final adminMember = GroupMember(
        groupId: group.id,
        userId: adminId,
        contributionAmount: contributionAmount,
      );
      await _groupRepository.addMemberToGroup(adminMember);

      // Generate initial collection schedule
      await _groupRepository.generateCollectionSchedule(group.id);

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> joinGroup(String inviteCode, String userId, double contributionAmount) async {
    _setLoading(true);
    try {
      final group = await _groupRepository.getGroupByInviteCode(inviteCode);
      if (group == null) {
        _error = 'Invalid invite code';
        _setLoading(false);
        return false;
      }

      // Check if user is already in the group
      if (await _groupRepository.isUserInGroup(userId, group.id)) {
        _error = 'You are already a member of this group';
        _setLoading(false);
        return false;
      }

      final member = GroupMember(
        groupId: group.id,
        userId: userId,
        contributionAmount: contributionAmount,
      );

      await _groupRepository.addMemberToGroup(member);
      
      // Regenerate collection schedule with new member
      await _groupRepository.generateCollectionSchedule(group.id);

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<void> loadGroupDetails(String groupId, String userId) async {
    _setLoading(true);
    try {
      _selectedGroup = await _groupRepository.getGroupById(groupId);
      if (_selectedGroup != null) {
        _groupMembers = await _groupRepository.getGroupMembersWithUserDetails(groupId);
        _collectionSchedule = await _groupRepository.getGroupCollectionScheduleWithUserDetails(groupId);
        _userCollectionInfo = await _groupRepository.getUserCollectionInfo(groupId, userId);
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadNextCollection(String userId) async {
    try {
      _nextCollection = await _groupRepository.getNextUserCollection(userId);
      // Don't call notifyListeners here to avoid setState during build
    } catch (e) {
      _error = e.toString();
      // Don't call notifyListeners here to avoid setState during build
    }
  }

  Future<bool> removeMemberFromGroup(String groupId, String userId, String currentUserId) async {
    _setLoading(true);
    try {
      await _groupRepository.removeMemberFromGroup(groupId, userId);
      
      // Regenerate collection schedule
      await _groupRepository.generateCollectionSchedule(groupId);
      
      // Reload group details
      await loadGroupDetails(groupId, currentUserId);
      
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deactivateGroup(String groupId) async {
    _setLoading(true);
    try {
      await _groupRepository.deactivateGroup(groupId);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> isUserGroupAdmin(String userId, String groupId) async {
    return await _groupRepository.isUserGroupAdmin(userId, groupId);
  }

  Future<int> getGroupMemberCount(String groupId) async {
    return await _groupRepository.getGroupMemberCount(groupId);
  }

  Future<double> getGroupTotalContributions(String groupId) async {
    return await _groupRepository.getGroupTotalContributions(groupId);
  }

  Future<Map<String, dynamic>> getUserCollectionInfo(String groupId, String userId) async {
    return await _groupRepository.getUserCollectionInfo(groupId, userId);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSelectedGroup() {
    _selectedGroup = null;
    _groupMembers.clear();
    _collectionSchedule.clear();
    _userCollectionInfo = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}