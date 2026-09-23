import 'package:flutter/material.dart';

import '../../../../core/backend/backend_config.dart';

import 'package:get/get.dart';

import '../../../../core/widgets/app_feedback.dart';
import '../../../../core/widgets/shop_widgets.dart';
import '../../../auth/domain/auth_validators.dart';
import '../../../auth/presentation/controllers/auth_controller.dart';
import '../../domain/customer_preferences.dart';
import '../controllers/profile_controller.dart';

String? phoneError(String? value, {bool required = false}) {
  final phone = (value ?? '').trim();
  if (!required && phone.isEmpty) return null;
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  return RegExp(r'^[+\d ()-]+$').hasMatch(phone) &&
          digits.length >= 7 &&
          digits.length <= 15
      ? null
      : 'Enter a valid phone number.';
}

class PersonalDetailsScreen extends StatefulWidget {
  const PersonalDetailsScreen({super.key});
  @override
  State<PersonalDetailsScreen> createState() => _PersonalDetailsScreenState();
}

class _PersonalDetailsScreenState extends State<PersonalDetailsScreen> {
  final _form = GlobalKey<FormState>();
  late final _name = TextEditingController(
    text: Get.find<AuthController>().user?.name,
  );
  late final _phone = TextEditingController(
    text: Get.find<ProfileController>().phone,
  );
  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = Get.find<AuthController>();
    final ok = await auth.updateName(_name.text);
    if (!mounted) return;
    if (!ok) {
      AppFeedback.show(context, auth.error ?? 'Please try again.', error: true);
      return;
    }
    Get.find<ProfileController>().savePhone(_phone.text);
    Navigator.pop(context);
    AppFeedback.show(context, 'Profile updated');
  }

  @override
  Widget build(BuildContext context) => _formPage(
    'Personal details',
    Form(
      key: _form,
      child: GetBuilder<AuthController>(
        builder: (auth) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(
              'A little about you',
              subtitle: 'The name we’ll put on your next cup.',
            ),
            TextFormField(
              key: const ValueKey('profile-name'),
              controller: _name,
              enabled: !auth.busy,
              validator: AuthValidators.name,
              textCapitalization: TextCapitalization.words,
              maxLength: 60,
              decoration: const InputDecoration(
                labelText: 'Full name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _phone,
              enabled: !auth.busy,
              validator: (value) => phoneError(value),
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number (optional)',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 20),
            ShopCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Email address',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(auth.user?.email ?? 'Preview account'),
                  const SizedBox(height: 6),
                  const Text('Your email identifies your account.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: auth.busy ? null : _save,
              child: Text(auth.busy ? 'Saving…' : 'Save details'),
            ),
          ],
        ),
      ),
    ),
  );
}

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});
  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final _form = GlobalKey<FormState>();
  late final _label = TextEditingController(
    text: Get.find<ProfileController>().address?.label ?? 'Home',
  );
  late final _street = TextEditingController(
    text: Get.find<ProfileController>().address?.street,
  );
  late final _city = TextEditingController(
    text: Get.find<ProfileController>().address?.city,
  );
  late final _phone = TextEditingController(
    text:
        Get.find<ProfileController>().address?.phone ??
        Get.find<ProfileController>().phone,
  );
  @override
  void dispose() {
    for (final field in [_label, _street, _city, _phone]) {
      field.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _formPage(
    'Delivery address',
    Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            'Where’s your coffee going?',
            subtitle: 'Save a delivery address for checkout.',
          ),
          TextFormField(
            controller: _label,
            maxLength: 30,
            decoration: const InputDecoration(labelText: 'Address label'),
            validator: (value) => (value ?? '').trim().isEmpty
                ? 'Give this address a label.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('address-street'),
            controller: _street,
            maxLength: 160,
            minLines: 2,
            maxLines: 3,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Street, building & apartment',
            ),
            validator: (value) => (value ?? '').trim().length < 5
                ? 'Enter your complete street address.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('address-city'),
            controller: _city,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'City / area'),
            validator: (value) => (value ?? '').trim().length < 2
                ? 'Enter your city or area.'
                : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            key: const ValueKey('address-phone'),
            controller: _phone,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Delivery phone number',
            ),
            validator: (value) => phoneError(value, required: true),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              Get.find<ProfileController>().saveAddress(
                DeliveryAddress(
                  label: _label.text.trim(),
                  street: _street.text.trim(),
                  city: _city.text.trim(),
                  phone: _phone.text.trim(),
                ),
              );
              Navigator.pop(context);
              AppFeedback.show(context, 'Delivery address saved');
            },
            child: const Text('Save address'),
          ),
          if (Get.find<ProfileController>().address != null)
            TextButton(
              onPressed: () async {
                if (!await confirmAction(
                  context,
                  title: 'Remove this address?',
                  message: 'You can add a new delivery address at any time.',
                  action: 'Remove',
                )) {
                  return;
                }
                Get.find<ProfileController>().saveAddress(null);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Remove saved address'),
            ),
        ],
      ),
    ),
  );
}

class PaymentMethodsScreen extends StatelessWidget {
  const PaymentMethodsScreen({super.key});
  @override
  Widget build(BuildContext context) => _formPage(
    'Payment preferences',
    GetBuilder<ProfileController>(
      builder: (profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(
            'Your preferred way to pay',
            subtitle: 'Choose a default for checkout. No money is collected in this preview.',
          ),
          for (final choice
              in BackendConfig.live
                  ? [PaymentChoice.cash]
                  : PaymentChoice.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: ShopCard(
                padding: EdgeInsets.zero,
                child: ListTile(
                  key: ValueKey('payment-${choice.name}'),
                  contentPadding: const EdgeInsets.all(18),
                  leading: Icon(
                    choice == PaymentChoice.cash
                        ? Icons.payments_outlined
                        : Icons.credit_card,
                  ),
                  title: Text(choice.label),
                  subtitle: Text(
                    choice == PaymentChoice.cash
                        ? 'Pay when you receive your coffee'
                        : 'Try the card flow without entering card details',
                  ),
                  trailing: Icon(
                    profile.payment == choice
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  onTap: () => profile.setPayment(choice),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            'Secure card entry and digital wallets will be available when payments are connected.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    ),
  );
}

class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});
  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _form = GlobalKey<FormState>();
  final _current = TextEditingController(),
      _password = TextEditingController(),
      _confirm = TextEditingController();
  final _hidden = [true, true, true];
  @override
  void dispose() {
    _current.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    final auth = Get.find<AuthController>();
    final ok = await auth.changePassword(_current.text, _password.text);
    if (!mounted) return;
    if (!ok) {
      AppFeedback.show(context, auth.error ?? 'Please try again.', error: true);
      return;
    }
    Navigator.pop(context);
    AppFeedback.show(context, 'Preview password updated');
  }

  @override
  Widget build(BuildContext context) => _formPage(
    'Security & password',
    Form(
      key: _form,
      child: GetBuilder<AuthController>(
        builder: (auth) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SectionTitle(
              'A fresh password',
              subtitle: 'Choose a strong password unique to this account.',
            ),
            for (final entry in [
              (0, 'Current password', _current),
              (1, 'New password', _password),
              (2, 'Confirm new password', _confirm),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 18),
                child: TextFormField(
                  key: ValueKey(entry.$2),
                  controller: entry.$3,
                  obscureText: _hidden[entry.$1],
                  enabled: !auth.busy,
                  autocorrect: false,
                  enableSuggestions: false,
                  validator: (value) => entry.$1 == 2
                      ? (value == _password.text
                            ? null
                            : 'Passwords do not match.')
                      : entry.$1 == 0
                      ? ((value ?? '').isEmpty
                            ? 'Enter your current password.'
                            : null)
                      : AuthValidators.password(value),
                  decoration: InputDecoration(
                    labelText: entry.$2,
                    suffixIcon: IconButton(
                      tooltip: _hidden[entry.$1]
                          ? 'Show password'
                          : 'Hide password',
                      onPressed: () => setState(
                        () => _hidden[entry.$1] = !_hidden[entry.$1],
                      ),
                      icon: Icon(
                        _hidden[entry.$1]
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                ),
              ),
            FilledButton(
              onPressed: auth.busy ? null : _save,
              child: Text(auth.busy ? 'Updating…' : 'Update password'),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _formPage(String title, Widget form) => Scaffold(
  appBar: AppBar(title: Text(title)),
  body: SafeArea(
    child: PageBody(
      maxWidth: 600,
      child: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: form,
      ),
    ),
  ),
);
