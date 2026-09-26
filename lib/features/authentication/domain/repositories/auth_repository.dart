import '../../../../shared/domain/entities/user_profile.dart';

abstract class AuthRepository {
  Future<UserProfile> signInWithEmail({required String email, required String password});
  Future<UserProfile> signUp({required String email, required String password, required String displayName});
  Future<UserProfile> signInWithGoogle();
  Future<UserProfile> signInWithApple();
  Future<UserProfile> continueAsGuest();
  Future<void> signOut();
  Future<UserProfile?> getCurrentUser();
  Future<void> requestPasswordReset({required String email});
  Future<void> changePassword({required String currentPassword, required String newPassword});
}
