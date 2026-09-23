import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this.client);
  final SupabaseClient client;
  AuthUser? get currentUser {
    final user = client.auth.currentUser;
    return user == null ? null : _map(user);
  }

  AuthUser _map(User user) => AuthUser(
    id: user.id,
    name: user.userMetadata?['name'] as String? ?? 'Coffee Lover',
    email: user.email ?? '',
  );
  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    }
  }

  @override
  Future<AuthUser> signInDemo() async =>
      throw const AuthFailure('Please create an account to continue.');
  @override
  Future<AuthUser> signIn(String email, String password) => _guard(() async {
    final response = await client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    return _map(response.user!);
  });
  @override
  Future<AuthUser> signUp(String name, String email, String password) =>
      _guard(() async {
        final response = await client.auth.signUp(
          email: email.trim(),
          password: password,
          data: {'name': name.trim()},
          emailRedirectTo: 'coffeeshop://auth-callback',
        );
        if (response.session == null) {
          throw const AuthFailure(
            'Check your email to confirm your account, then sign in.',
          );
        }
        return _map(response.user!);
      });
  @override
  Future<void> requestPasswordReset(String email) => _guard(
    () => client.auth.resetPasswordForEmail(
      email.trim(),
      redirectTo: 'coffeeshop://auth-callback',
    ),
  );
  @override
  Future<void> signOut() => _guard(() => client.auth.signOut());
  @override
  Future<AuthUser> updateName(String email, String name) => _guard(() async {
    final response = await client.auth.updateUser(
      UserAttributes(data: {'name': name.trim()}),
    );
    return _map(response.user!);
  });
  @override
  Future<void> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) => _guard(() async {
    await client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await client.auth.updateUser(UserAttributes(password: newPassword));
  });
}
