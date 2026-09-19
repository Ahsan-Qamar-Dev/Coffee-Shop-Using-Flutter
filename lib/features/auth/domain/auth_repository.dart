import 'auth_user.dart';

abstract class AuthRepository {
  Future<AuthUser> signInDemo();
  Future<AuthUser> signIn(String email, String password);
  Future<AuthUser> signUp(String name, String email, String password);
  Future<void> requestPasswordReset(String email);
  Future<void> signOut();
  Future<AuthUser> updateName(String email, String name);
  Future<void> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  );
}
