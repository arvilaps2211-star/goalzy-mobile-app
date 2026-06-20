import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../shared/domain/entities/user_profile.dart';
import '../../data/repositories/mock_auth_repository.dart';
import '../../domain/repositories/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return MockAuthRepository(ref.watch(supabaseClientProvider));
});

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isGuest = false,
    this.error,
  });

  final UserProfile? user;
  final bool isLoading;
  final bool isGuest;
  final String? error;

  bool get isAuthenticated => user != null && !isGuest;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState());

  final AuthRepository _repo;

  Future<void> signInWithEmail(String email, String password) async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.signInWithEmail(email: email, password: password);
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> signInWithGoogle() async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.signInWithGoogle();
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> signInWithApple() async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.signInWithApple();
      state = AuthState(user: user);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> continueAsGuest() async {
    state = const AuthState(isLoading: true);
    try {
      final user = await _repo.continueAsGuest();
      state = AuthState(user: user, isGuest: true);
    } catch (e) {
      state = AuthState(error: e.toString());
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState();
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserProfile?>((ref) => ref.watch(authStateProvider).user);
