import '../domain/auth_repository.dart';
import '../domain/auth_user.dart';

/// Preview only. In-memory credentials disappear on restart; never use real passwords.
/// Replace this adapter with an API implementation before release.
class DemoAuthRepository implements AuthRepository {
  @override
  Future<AuthUser> signInDemo() async {
    await _delay();
    return _accounts['demo@coffee.test']!.user;
  }

  final Map<String, ({AuthUser user, String password})> _accounts = {
    'demo@coffee.test': (
      user: const AuthUser(name: 'Coffee Lover', email: 'demo@coffee.test'),
      password: 'Coffee123!',
    ),
  };
  Future<void> _delay() =>
      Future<void>.delayed(const Duration(milliseconds: 250));
  @override
  Future<AuthUser> signIn(String email, String password) async {
    await _delay();
    final account = _accounts[email.trim().toLowerCase()];
    if (account == null || account.password != password) {
      throw const AuthFailure(
        'Email or password is incorrect. Use the demo account or create a preview account.',
      );
    }
    return account.user;
  }

  @override
  Future<AuthUser> signUp(String name, String email, String password) async {
    await _delay();
    final key = email.trim().toLowerCase();
    if (_accounts.containsKey(key)) {
      throw const AuthFailure(
        'This email already has a preview account. Please sign in.',
      );
    }
    final user = AuthUser(name: name.trim(), email: key);
    _accounts[key] = (user: user, password: password);
    return user;
  }

  @override
  Future<void> requestPasswordReset(String email) => _delay();
  @override
  Future<void> signOut() async {}

  @override
  Future<AuthUser> updateName(String email, String name) async {
    await _delay();
    final account = _accounts[email];
    if (account == null) throw const AuthFailure('Please sign in again.');
    final user = AuthUser(name: name.trim(), email: email);
    _accounts[email] = (user: user, password: account.password);
    return user;
  }

  @override
  Future<void> changePassword(
    String email,
    String currentPassword,
    String newPassword,
  ) async {
    await _delay();
    final account = _accounts[email];
    if (account == null || account.password != currentPassword) {
      throw const AuthFailure('Your current password is incorrect.');
    }
    if (newPassword.length < 8) {
      throw const AuthFailure('Use at least 8 characters.');
    }
    _accounts[email] = (user: account.user, password: newPassword);
  }
}
