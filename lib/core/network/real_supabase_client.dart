import 'package:supabase_flutter/supabase_flutter.dart' as sb;

import 'supabase_client_stub.dart';

/// Real Supabase-backed implementation of [SupabaseClientStub].
///
/// Only ever constructed when `BackendConfig.isConfigured` is true (see
/// core/di/providers.dart) — `Supabase.initialize()` must already have run
/// in main.dart's bootstrap before anything calls into this class.
///
/// Scope, deliberately: this fully implements real Supabase Auth (sign in,
/// OAuth, sign out, session restore) because `AuthRepository` already had a
/// clean, stable interface with a proven mock/real parity story from Stage
/// 2. The generic `select`/`insert`/`update` methods below are real and
/// usable, but nothing in the app actually calls them yet — every feature
/// repository (tasks, habits, goals, etc.) still reads from its own
/// in-memory mock list, not from a real Supabase table. Migrating those is
/// real, feature-by-feature work for a future pass, not something to do
/// unilaterally in one sweep without an actual project to test each one
/// against. See /supabase/BACKEND_SETUP.md.
class RealSupabaseClient implements SupabaseClientStub {
  sb.SupabaseClient get _client => sb.Supabase.instance.client;

  @override
  Future<Map<String, dynamic>?> authSignInWithPassword({
    required String email,
    required String password,
  }) async {
    final res = await _client.auth.signInWithPassword(email: email, password: password);
    if (res.session == null || res.user == null) return null;
    return {
      'user': {'id': res.user!.id, 'email': res.user!.email},
    };
  }

  @override
  Future<Map<String, dynamic>?> authSignInWithOAuth(String provider) async {
    final oauthProvider = provider == 'google' ? sb.OAuthProvider.google : sb.OAuthProvider.apple;
    // signInWithOAuth opens an external browser/redirect flow — unlike
    // password sign-in, the resulting session doesn't come back as a
    // return value here, it arrives asynchronously once the redirect
    // completes. authGetSession() below picks it up at that point.
    await _client.auth.signInWithOAuth(oauthProvider);
    return authGetSession();
  }

  @override
  Future<void> authSignOut() => _client.auth.signOut();

  @override
  Future<Map<String, dynamic>?> authGetSession() async {
    final session = _client.auth.currentSession;
    if (session == null) return null;
    return {
      'user': {'id': session.user.id, 'email': session.user.email},
    };
  }

  @override
  Future<List<Map<String, dynamic>>> select(String table) async {
    final rows = await _client.from(table).select();
    return List<Map<String, dynamic>>.from(rows as List);
  }

  @override
  Future<Map<String, dynamic>> insert(String table, Map<String, dynamic> data) async {
    return _client.from(table).insert(data).select().single();
  }

  @override
  Future<Map<String, dynamic>> update(String table, Map<String, dynamic> data) async {
    final id = data['id'];
    if (id == null) {
      throw ArgumentError('update() requires an "id" key in data to know which row to update');
    }
    return _client.from(table).update(data).eq('id', id).select().single();
  }

  @override
  Future<void> delete(String table) async {
    // The inherited interface (SupabaseClientStub.delete(table)) has no
    // row identifier parameter — implementing this "for real" would mean
    // deleting every row in the table, which is exactly the kind of
    // destructive, unscoped operation this integration should never do.
    // Left as a clear, loud error instead of a silently dangerous no-op
    // or a real-but-wrong implementation. The interface needs a
    // delete(table, id) signature before this can be done safely — see
    // /supabase/BACKEND_SETUP.md.
    throw UnimplementedError(
      'delete(table) has no row id to scope to. The SupabaseClientStub '
      'interface needs a delete(table, id) signature before a real, safe '
      'implementation is possible — see /supabase/BACKEND_SETUP.md.',
    );
  }
}
