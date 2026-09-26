import 'package:shared_preferences/shared_preferences.dart';

/// Stub for future Supabase integration.
/// Replace with real SupabaseClient when connecting backend.
abstract class SupabaseClientStub {
  Future<Map<String, dynamic>?> authSignInWithPassword({
    required String email,
    required String password,
  });

  Future<Map<String, dynamic>?> authSignInWithOAuth(String provider);
  Future<void> authSignOut();
  Future<Map<String, dynamic>?> authGetSession();

  Future<List<Map<String, dynamic>>> select(String table);
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data);
  Future<Map<String, dynamic>> update(String table, Map<String, dynamic> data);
  Future<void> delete(String table);
}

/// A real Supabase client persists and restores sessions on its own (secure
/// storage + JWT refresh) — this mock simulates that same contract with
/// SharedPreferences, so [authGetSession] genuinely has something to
/// restore instead of always returning null, and the repository/notifier
/// layers above don't need to change shape when a real client replaces
/// this one later.
class MockSupabaseClient implements SupabaseClientStub {
  static const _sessionKey = 'mock_session_user';

  @override
  Future<Map<String, dynamic>?> authSignInWithPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final session = {'user': {'id': 'mock-user-1', 'email': email}};
    await _persistSession(email);
    return session;
  }

  @override
  Future<Map<String, dynamic>?> authSignInWithOAuth(String provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    final email = '$provider@goalzy.app';
    final session = {'user': {'id': 'mock-user-1', 'email': email}};
    await _persistSession(email);
    return session;
  }

  @override
  Future<void> authSignOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  @override
  Future<Map<String, dynamic>?> authGetSession() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_sessionKey);
    if (email == null) return null;
    return {'user': {'id': 'mock-user-1', 'email': email}};
  }

  Future<void> _persistSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, email);
  }

  @override
  Future<List<Map<String, dynamic>>> select(String table) async => [];

  @override
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async => data;

  @override
  Future<Map<String, dynamic>> update(String table, Map<String, dynamic> data) async => data;

  @override
  Future<void> delete(String table) async {}
}
