import '../../../../shared/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> signInWithEmail({required String email, required String password});
  Future<UserProfile> signInWithGoogle();
  Future<UserProfile> signInWithApple();
  Future<UserProfile> continueAsGuest();
  Future<void> signOut();
  Future<UserProfile?> getCurrentUser();
}
