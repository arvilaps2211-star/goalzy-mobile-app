import 'package:uuid/uuid.dart';

import '../../../../core/network/supabase_client_stub.dart';
import '../../../../shared/data/mock_data.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../domain/repositories/auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  MockAuthRepository(this._client);

  final SupabaseClientStub _client;
  UserProfile? _currentUser;

  @override
  Future<UserProfile> signInWithEmail({required String email, required String password}) async {
    await _client.authSignInWithPassword(email: email, password: password);
    _currentUser = MockData.user.copyWith(email: email);
    return _currentUser!;
  }

  @override
  Future<UserProfile> signUp({required String email, required String password, required String displayName}) async {
    // A real signup starts a fresh account (UserProfile's own defaults:
    // level 1, 0 XP, no streak) rather than inheriting MockData.user's
    // established stats the way sign-in does for the demo account.
    _currentUser = UserProfile(
      id: const Uuid().v4(),
      email: email,
      displayName: displayName,
      createdAt: DateTime.now(),
    );
    // New account is signed in immediately, same as any other sign-in —
    // reuses the same session-persistence path rather than a separate one.
    await _client.authSignInWithPassword(email: email, password: password);
    return _currentUser!;
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    await _client.authSignInWithOAuth('google');
    _currentUser = MockData.user;
    return _currentUser!;
  }

  @override
  Future<UserProfile> signInWithApple() async {
    await _client.authSignInWithOAuth('apple');
    _currentUser = MockData.user;
    return _currentUser!;
  }

  @override
  Future<UserProfile> continueAsGuest() async {
    _currentUser = MockData.user.copyWith(displayName: 'Guest User', email: 'guest@goalzy.app');
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    await _client.authSignOut();
    _currentUser = null;
  }

  @override
  Future<UserProfile?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    // Guest sessions are intentionally never persisted (see continueAsGuest
    // below) — only a real sign-in leaves something in _client to restore.
    final session = await _client.authGetSession();
    final email = (session?['user'] as Map?)?['email'] as String?;
    if (email == null) return null;
    _currentUser = MockData.user.copyWith(email: email);
    return _currentUser;
  }

  @override
  Future<void> requestPasswordReset({required String email}) async {
    // No real email delivery exists in this mock backend — this simulates
    // the network round trip so the UI's "check your email" confirmation
    // state is genuine (has to actually wait), not instant/fake-feeling.
    await Future<void>.delayed(const Duration(milliseconds: 900));
  }

  @override
  Future<void> changePassword({required String currentPassword, required String newPassword}) async {
    // The mock backend never tracked real credentials to begin with (any
    // email/password combination already "works" for sign-in), so there's
    // nothing to validate against here beyond what the UI already checks
    // (non-empty, matching confirmation, minimum length) before calling
    // this. Simulates the round trip the same way requestPasswordReset does.
    await Future<void>.delayed(const Duration(milliseconds: 700));
  }
}
