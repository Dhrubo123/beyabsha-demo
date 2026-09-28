import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/app_shell.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/splash_screen.dart';
import 'repositories/api_repository.dart';
import 'services/api_client.dart';
import 'services/app_store.dart';
import 'services/language_store.dart';

class ByabshaApp extends StatelessWidget {
  const ByabshaApp({super.key});
  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppStore(ApiRepository(ApiClient()))),
      ChangeNotifierProvider(create: (_) => LanguageStore()..load()),
    ],
    child: Builder(
      builder: (context) => LanguageScope(
        store: context.watch<LanguageStore>(), code: context.watch<LanguageStore>().code,
        child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      routerConfig: GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (_, _) => const SplashScreen()),
          GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
          GoRoute(path: '/register', builder: (_, _) => const RegisterScreen()),
          GoRoute(path: '/app', builder: (_, _) => const AppShell()),
        ],
      ),
        ),
      ),
    ),
  );
}

