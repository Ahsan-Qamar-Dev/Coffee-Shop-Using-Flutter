import 'package:get/get.dart';

import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

class AuthController extends GetxController {
  final AuthRepository repository;
  AuthController(this.repository);
  Future<void> Function()? loadSession;
  Future<void> Function()? beforeSignOut;
  void Function()? clearSession;
  bool busy = false;
  String? error;
  AuthUser? user;
  Future<bool> signInDemo() => _run(() async {
    user = await repository.signInDemo();
  });
  Future<bool> _run(Future<void> Function() action) async {
    if (busy) return false;
    busy = true;
    error = null;
    update();
    try {
      await action();
      return true;
    } on AuthFailure catch (e) {
      error = e.message;
      return false;
    } catch (_) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      busy = false;
      update();
    }
  }

  Future<bool> signIn(String email, String password) => _run(() async {
    final signedIn = await repository.signIn(email, password);
    await loadSession?.call();
    user = signedIn;
  });
  Future<bool> signUp(String name, String email, String password) =>
      _run(() async {
        final signedUp = await repository.signUp(name, email, password);
        await loadSession?.call();
        user = signedUp;
      });
  Future<bool> resetPassword(String email) =>
      _run(() => repository.requestPasswordReset(email));
  Future<bool> updateName(String name) => _run(() async {
    if (user == null) throw const AuthFailure('Please sign in again.');
    user = await repository.updateName(user!.email, name);
  });
  Future<bool> changePassword(String currentPassword, String newPassword) =>
      _run(() async {
        if (user == null) throw const AuthFailure('Please sign in again.');
        await repository.changePassword(
          user!.email,
          currentPassword,
          newPassword,
        );
      });
  Future<bool> signOut() => _run(() async {
    await beforeSignOut?.call();
    await repository.signOut();
    clearSession?.call();
    user = null;
  });
}
