import '../database/database_helper.dart';
import '../models/user.dart';

class UserRepository {
  final DatabaseHelper _db = DatabaseHelper();

  Future<User> createUser(User user) async {
    await _db.insert('users', user.toMap());
    return user;
  }

  Future<User?> getUserById(String userId) async {
    final result = await _db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<User?> getUserByUsername(String username) async {
    final result = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (result.isEmpty) return null;
    return User.fromMap(result.first);
  }

  Future<List<User>> getAllUsers() async {
    final result = await _db.query('users', orderBy: 'created_at DESC');
    return result.map((map) => User.fromMap(map)).toList();
  }

  Future<void> updateUser(User user) async {
    await _db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<void> deleteUser(String userId) async {
    await _db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  Future<bool> usernameExists(String username) async {
    final result = await _db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  Future<bool> emailExists(String email) async {
    final result = await _db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }
}