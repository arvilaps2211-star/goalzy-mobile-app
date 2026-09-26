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
    this.isRestoring = true,
    this.error,
  });

  final UserProfile? user;
  final bool isLoading;
  final bool isGuest;

  /// True only during the initial session check on app startup — distinct
  /// from [isLoading] (used for actual sign-in attempts) so Splash can
  /// wait specifically for "have we checked for an existing session yet"
  /// without being confused by a later sign-in's own loading state.
  final bool isRestoring;
  final String? error;

  bool get isAuthenticated => user != null && !isGuest;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repo) : super(const AuthState()) {
    _restoreFuture = _restoreSession();
  }

  final AuthRepository _repo;
  late final Future<void> _restoreFuture;

  /// Resolves once the initial session-restoration check has completed,
  /// whether or not a session was actually found. Safe to await multiple
  /// times (e.g. from Splash) — it's the same cached Future each time,
  /// not a new check.
  Future<void> ensureRestored() => _restoreFuture;

  Future<void> _restoreSession() async {
    try {
      final user = await _repo.getCurrentUser();
      state = AuthState(user: user, isRestoring: false);
    } catch (_) {
      // A failed restore should never block the user at a blank screen —
      // fall through to the signed-out state, same as no session found.
      state = const AuthState(isRestoring: false);
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = AuthState(isLoading: true, isRestoring: state.isRestoring);
    try {
      final user = await _repo.signInWithEmail(email: email, password: password);
      state = AuthState(user: user, isRestoring: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isRestoring: false);
    }
  }

  Future<void> signUp({required String email, required String password, required String displayName}) async {
    state = AuthState(isLoading: true, isRestoring: state.isRestoring);
    try {
      final user = await _repo.signUp(email: email, password: password, displayName: displayName);
      state = AuthState(user: user, isRestoring: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isRestoring: false);
    }
  }

  Future<void> signInWithGoogle() async {
    state = AuthState(isLoading: true, isRestoring: state.isRestoring);
    try {
      final user = await _repo.signInWithGoogle();
      state = AuthState(user: user, isRestoring: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isRestoring: false);
    }
  }

  Future<void> signInWithApple() async {
    state = AuthState(isLoading: true, isRestoring: state.isRestoring);
    try {
      final user = await _repo.signInWithApple();
      state = AuthState(user: user, isRestoring: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isRestoring: false);
    }
  }

  Future<void> continueAsGuest() async {
    state = AuthState(isLoading: true, isRestoring: state.isRestoring);
    try {
      final user = await _repo.continueAsGuest();
      state = AuthState(user: user, isGuest: true, isRestoring: false);
    } catch (e) {
      state = AuthState(error: e.toString(), isRestoring: false);
    }
  }

  Future<void> signOut() async {
    await _repo.signOut();
    state = const AuthState(isRestoring: false);
  }

  /// These two don't touch AuthState.user/isLoading — the calling screen
  /// (Forgot Password, Settings' change-password sheet) manages its own
  /// local loading state, same pattern already used by GoalCreateScreen
  /// and the Tasks quick-add sheet for form submissions.
  Future<void> requestPasswordReset(String email) => _repo.requestPasswordReset(email: email);

  Future<void> changePassword({required String currentPassword, required String newPassword}) =>
      _repo.changePassword(currentPassword: currentPassword, newPassword: newPassword);
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

final currentUserProvider = Provider<UserProfile?>((ref) => ref.watch(authStateProvider).user);
