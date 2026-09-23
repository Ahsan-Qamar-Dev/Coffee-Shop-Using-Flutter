import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/backend/backend_config.dart';

import '../../../../core/widgets/app_feedback.dart';

import 'package:my_coffee_shop/features/catalog/presentation/pages/home_page.dart';

import '../../domain/auth_validators.dart';
import '../controllers/auth_controller.dart';

enum AuthPageMode { signIn, signUp, reset }

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});
  @override
  Widget build(BuildContext context) =>
      const AuthPage(mode: AuthPageMode.signIn);
}

class AuthPage extends StatefulWidget {
  final AuthPageMode mode;
  const AuthPage({super.key, required this.mode});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  bool _hidden = true;
  bool _confirmHidden = true;
  bool _submitted = false;
  bool _resetSent = false;
  bool get _signup => widget.mode == AuthPageMode.signUp;
  bool get _reset => widget.mode == AuthPageMode.reset;
  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final auth = Get.find<AuthController>();
    if (auth.busy) return;
    setState(() => _submitted = true);
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final ok = _reset
        ? await auth.resetPassword(_email.text)
        : _signup
        ? await auth.signUp(_name.text, _email.text, _password.text)
        : await auth.signIn(_email.text, _password.text);
    if (!mounted) return;
    if (!ok) {
      AppFeedback.show(context, auth.error ?? 'Please try again.', error: true);
      return;
    }
    if (_reset) {
      setState(() => _resetSent = true);
      AppFeedback.show(
        context,
        BackendConfig.live
            ? 'Check your inbox for a password reset link.'
            : 'Preview complete. No reset email was sent.',
      );
    } else {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      Get.offAll(() => const HomePage());
    }
  }

  void _open(AuthPageMode mode) {
    if (Get.find<AuthController>().busy) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => AuthPage(mode: mode)));
  }

  Future<void> _tryDemo() async {
    final auth = Get.find<AuthController>();
    if (auth.busy) return;
    FocusScope.of(context).unfocus();
    final ok = await auth.signInDemo();
    if (!mounted) return;
    if (!ok) {
      AppFeedback.show(context, auth.error ?? 'Please try again.', error: true);
      return;
    }
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Get.offAll(() => const HomePage());
  }

  Widget _field({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    bool password = false,
    bool confirm = false,
    TextInputAction action = TextInputAction.next,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        key: ValueKey(label),
        controller: controller,
        enabled: enabled,
        validator: validator,
        obscureText: password && (confirm ? _confirmHidden : _hidden),
        autocorrect: !password,
        enableSuggestions: !password,
        keyboardType: label == 'Email address'
            ? TextInputType.emailAddress
            : TextInputType.text,
        textInputAction: action,
        onFieldSubmitted: (_) {
          if (action == TextInputAction.done) _submit();
        },
        autofillHints: password
            ? [_signup ? AutofillHints.newPassword : AutofillHints.password]
            : label == 'Email address'
            ? [AutofillHints.email]
            : [AutofillHints.name],
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: password
              ? IconButton(
                  tooltip: (confirm ? _confirmHidden : _hidden)
                      ? 'Show password'
                      : 'Hide password',
                  onPressed: () => setState(() {
                    if (confirm) {
                      _confirmHidden = !_confirmHidden;
                    } else {
                      _hidden = !_hidden;
                    }
                  }),
                  icon: Icon(
                    (confirm ? _confirmHidden : _hidden)
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final title = _reset
        ? 'Forgot Password?'
        : _signup
        ? 'Create Account'
        : 'Welcome Back!';
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: GetBuilder<AuthController>(
                  builder: (auth) => Form(
                    key: _form,
                    autovalidateMode: _submitted
                        ? AutovalidateMode.onUserInteraction
                        : AutovalidateMode.disabled,
                    child: AutofillGroup(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (widget.mode != AuthPageMode.signIn)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: IconButton(
                                tooltip: 'Back to sign in',
                                onPressed: auth.busy
                                    ? null
                                    : () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back_ios_new),
                              ),
                            ),
                          Center(
                            child: Container(
                              width: 112,
                              height: 112,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: .15),
                                shape: BoxShape.circle,
                              ),
                              child: Image.asset(
                                'assets/Coffee_Cup.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _reset
                                ? 'Let’s get you back to your favorite coffee.'
                                : _signup
                                ? 'Your next coffee moment starts here.'
                                : 'Login to order your favorite coffee',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: colors.primary.withValues(alpha: .09),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'Preview mode · Use a test password. Accounts last only until restart; no real accounts or emails are created.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (_signup)
                            _field(
                              label: 'Full name',
                              controller: _name,
                              icon: Icons.person_outline,
                              validator: AuthValidators.name,
                              enabled: !auth.busy,
                            ),
                          _field(
                            label: 'Email address',
                            controller: _email,
                            icon: Icons.email_outlined,
                            validator: AuthValidators.email,
                            action: _reset
                                ? TextInputAction.done
                                : TextInputAction.next,
                            enabled: !auth.busy,
                          ),
                          if (!_reset)
                            _field(
                              label: 'Password',
                              controller: _password,
                              icon: Icons.lock_outline,
                              validator: AuthValidators.password,
                              password: true,
                              action: _signup
                                  ? TextInputAction.next
                                  : TextInputAction.done,
                              enabled: !auth.busy,
                            ),
                          if (_signup)
                            _field(
                              label: 'Confirm password',
                              controller: _confirm,
                              icon: Icons.lock_outline,
                              validator: (value) =>
                                  value == _password.text &&
                                      (value ?? '').isNotEmpty
                                  ? null
                                  : 'Passwords do not match.',
                              password: true,
                              confirm: true,
                              action: TextInputAction.done,
                              enabled: !auth.busy,
                            ),
                          if (!_signup && !_reset)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: auth.busy
                                    ? null
                                    : () => _open(AuthPageMode.reset),
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                          if (_resetSent)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: Text(
                                BackendConfig.live
                                    ? 'If this account exists, a reset link will be sent. Check your inbox and spam folder.'
                                    : 'Recovery preview complete. Email delivery will be available when the backend is connected.',
                                style: TextStyle(color: colors.primary),
                              ),
                            ),
                          const SizedBox(height: 8),
                          FilledButton(
                            key: const ValueKey('auth-submit'),
                            onPressed: auth.busy ? null : _submit,
                            child: auth.busy
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    _reset
                                        ? (BackendConfig.live
                                              ? 'Send reset link'
                                              : 'Preview password reset')
                                        : _signup
                                        ? (BackendConfig.live
                                              ? 'Create account'
                                              : 'Create preview account')
                                        : 'Sign In',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          if (widget.mode == AuthPageMode.signIn) ...[
                            if (!BackendConfig.live)
                              OutlinedButton(
                                onPressed: auth.busy ? null : _tryDemo,
                                child: const Text('Try demo account'),
                              ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                const Text("Don't have an account?"),
                                TextButton(
                                  onPressed: auth.busy
                                      ? null
                                      : () => _open(AuthPageMode.signUp),
                                  child: const Text('Register'),
                                ),
                              ],
                            ),
                          ] else
                            TextButton(
                              onPressed: auth.busy
                                  ? null
                                  : () => Navigator.pop(context),
                              child: const Text('Back to Sign In'),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
