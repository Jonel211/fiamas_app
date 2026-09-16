import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/stores/presentation/screens/my_stores_screen.dart';
import 'features/stores/presentation/screens/new_store_screen.dart';
import 'features/dashboard/presentation/screens/store_summary_screen.dart';

void main() {
  runApp(const FiamasApp());
}

/// Rutas con nombre para poder navegar entre TODAS las pantallas mientras
/// se arma la parte visual, sin depender de login real ni de datos.
/// Ej: Navigator.pushNamed(context, AppRoutes.stores);
class AppRoutes {
  AppRoutes._();
  static const login = '/';
  static const register = '/register';
  static const stores = '/stores';
  static const newStore = '/new-store';
  static const summary = '/summary';
}

class FiamasApp extends StatelessWidget {
  const FiamasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiamas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.login,
      routes: {
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.stores: (_) => const MyStoresScreen(),
        AppRoutes.newStore: (_) => const NewStoreScreen(),
        AppRoutes.summary: (_) => const StoreSummaryScreen(),
      },
    );
  }
}