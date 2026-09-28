import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/app_store.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _business = TextEditingController();
  final _branch = TextEditingController(text: 'Head Office');
  final _owner = TextEditingController();
  final _email = TextEditingController();
  final _mobile = TextEditingController();
  final _address = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    for (final controller in [
      _business,
      _branch,
      _owner,
      _email,
      _mobile,
      _address,
      _password,
      _confirmPassword,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AppStore>().registerBusiness(
        businessName: _business.text.trim(),
        branchName: _branch.text.trim(),
        ownerName: _owner.text.trim(),
        email: _email.text.trim(),
        mobile: _mobile.text.trim(),
        address: _address.text.trim(),
        password: _password.text,
      );
      if (mounted) context.go('/app');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is ApiException ? e.message : '$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    return Scaffold(
      appBar: AppBar(title: const Text('নতুন ব্যবসা রেজিস্টার করুন')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.business_center_rounded,
                      size: 54,
                      color: AppColors.green,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'আপনার ডিলারশিপ শুরু করুন',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'একটি কোম্পানি, প্রধান শাখা এবং মালিকের লগইন অ্যাকাউন্ট তৈরি হবে।',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    _field(
                      _business,
                      'কোম্পানি / ব্যবসার নাম',
                      Icons.store,
                      required: true,
                    ),
                    _field(
                      _branch,
                      'প্রধান শাখার নাম',
                      Icons.account_balance,
                      required: true,
                    ),
                    _field(_owner, 'মালিকের নাম', Icons.person, required: true),
                    _field(
                      _email,
                      'ইমেইল',
                      Icons.email_outlined,
                      required: true,
                      type: TextInputType.emailAddress,
                      extraValidator: (value) => value != null &&
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)
                          ? 'সঠিক ইমেইল দিন'
                          : null,
                    ),
                    _field(
                      _mobile,
                      'মোবাইল নম্বর (ঐচ্ছিক)',
                      Icons.phone,
                      type: TextInputType.phone,
                    ),
                    _field(
                      _address,
                      'ব্যবসার ঠিকানা (ঐচ্ছিক)',
                      Icons.location_on_outlined,
                      maxLines: 2,
                    ),
                    _passwordField(_password, 'পাসওয়ার্ড'),
                    _passwordField(_confirmPassword, 'পাসওয়ার্ড নিশ্চিত করুন',
                        validator: (value) => value != _password.text
                            ? 'দুইটি পাসওয়ার্ড এক নয়'
                            : null),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: store.loading ? null : _submit,
                      child: store.loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('অ্যাকাউন্ট তৈরি করুন'),
                    ),
                    TextButton(
                      onPressed: store.loading ? null : () => context.go('/login'),
                      child: const Text('আগে থেকে অ্যাকাউন্ট আছে? লগইন করুন'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool required = false,
    TextInputType? type,
    int maxLines = 1,
    String? Function(String?)? extraValidator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      keyboardType: type,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
      validator: (value) {
        if (required && (value == null || value.trim().isEmpty)) {
          return '$label দিন';
        }
        return extraValidator?.call(value?.trim());
      },
    ),
  );

  Widget _passwordField(
    TextEditingController controller,
    String label, {
    String? Function(String?)? validator,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: TextFormField(
      controller: controller,
      obscureText: _obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          onPressed: () => setState(() => _obscure = !_obscure),
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
        ),
      ),
      validator: (value) {
        if (value == null || value.length < 8) {
          return 'কমপক্ষে ৮ অক্ষরের পাসওয়ার্ড দিন';
        }
        return validator?.call(value);
      },
    ),
  );
}
