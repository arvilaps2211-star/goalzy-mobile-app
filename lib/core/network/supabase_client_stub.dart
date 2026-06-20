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

class MockSupabaseClient implements SupabaseClientStub {
  @override
  Future<Map<String, dynamic>?> authSignInWithPassword({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return {'user': {'id': 'mock-user-1', 'email': email}};
  }

  @override
  Future<Map<String, dynamic>?> authSignInWithOAuth(String provider) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    return {'user': {'id': 'mock-user-1', 'email': '$provider@goalzy.app'}};
  }

  @override
  Future<void> authSignOut() async {}

  @override
  Future<Map<String, dynamic>?> authGetSession() async => null;

  @override
  Future<List<Map<String, dynamic>>> select(String table) async => [];

  @override
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async => data;

  @override
  Future<Map<String, dynamic>> update(String table, Map<String, dynamic> data) async => data;

  @override
  Future<void> delete(String table) async {}
}
