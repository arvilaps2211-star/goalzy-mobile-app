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
  Future<UserProfile?> getCurrentUser() async => _currentUser;
}
