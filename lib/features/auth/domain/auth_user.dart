class AuthUser {
  final String id;
  final String name;
  final String email;
  const AuthUser({this.id = '', required this.name, required this.email});
}

class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
}
