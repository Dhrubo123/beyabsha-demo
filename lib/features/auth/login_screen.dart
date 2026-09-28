import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/app_store.dart';
import '../../services/language_store.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _login = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _login.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    try {
      await context.read<AppStore>().login(_login.text.trim(), _password.text);
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
    final l = context.tr;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Align(alignment: Alignment.centerRight, child: LanguageMenu()),
                    const Icon(Icons.account_balance_rounded, size: 64, color: AppColors.green),
                    const SizedBox(height: 16),
                    Text('Byabsha 360', textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold, color: AppColors.darkGreen)),
                    Text(l('liveBusinessInfo'), textAlign: TextAlign.center),
                    const SizedBox(height: 32),
                    Text(l('login'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _login,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(labelText: l('emailOrMobile'), prefixIcon: const Icon(Icons.person)),
                      validator: (v) => v == null || v.trim().isEmpty ? l('enterEmailOrMobile') : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _password,
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        labelText: l('password'),
                        prefixIcon: const Icon(Icons.lock),
                        suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure), icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off)),
                      ),
                      validator: (v) => v == null || v.length < 8 ? l('passwordLength') : null,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: store.loading ? null : _submit,
                      child: store.loading ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2)) : Text(l('login')),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: store.loading ? null : () => context.go('/register'),
                      icon: const Icon(Icons.storefront_outlined),
                      label: Text(l('registerBusiness')),
                    ),
                    const SizedBox(height: 8),
                    Text(l('registerHelp'), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    Text('API: ${ApiClient.baseUrl}', textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
