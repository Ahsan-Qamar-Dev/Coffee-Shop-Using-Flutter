import 'package:get/get.dart';

import '../../domain/auth_repository.dart';
import '../../domain/auth_user.dart';

class AuthController extends GetxController {
  final AuthRepository repository;
  AuthController(this.repository);
  bool busy = false;
  String? error;
  AuthUser? user;
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
    user = await repository.signIn(email, password);
  });
  Future<bool> signUp(String name, String email, String password) =>
      _run(() async {
        user = await repository.signUp(name, email, password);
      });
  Future<bool> resetPassword(String email) =>
      _run(() => repository.requestPasswordReset(email));
  Future<bool> signOut() => _run(() async {
    await repository.signOut();
    user = null;
  });
}
