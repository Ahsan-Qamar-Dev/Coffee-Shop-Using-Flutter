class AuthValidators {
  static String? name(String? value) => (value ?? '').trim().length < 2
      ? 'Enter your name (at least 2 characters).'
      : null;
  static String? email(String? value) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch((value ?? '').trim())
      ? null
      : 'Enter a valid email address.';
  static String? password(String? value) =>
      (value ?? '').length >= 8 ? null : 'Use at least 8 characters.';
}
