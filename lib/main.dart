import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/register_client_screen.dart';
import 'features/auth/presentation/screens/verification_screen.dart';
import 'features/menu/presentation/screens/menu_screen.dart';
import 'features/stores/presentation/screens/my_stores_screen.dart';
import 'features/stores/presentation/screens/new_store_screen.dart';
import 'features/dashboard/presentation/screens/store_summary_screen.dart';
import 'features/inventory/presentation/screens/products_screen.dart';
import 'features/inventory/presentation/screens/new_product_screen.dart';
import 'features/debts/presentation/screens/debts_screen.dart';
import 'features/help/presentation/screens/help_screen.dart';

void main() {
  runApp(const FiamasApp());
}

/// Rutas con nombre para poder navegar entre TODAS las pantallas mientras
/// se arma la parte visual, sin depender de login real ni de datos.
/// Ej: Navigator.pushNamed(context, AppRoutes.stores);
class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const registerClient = '/register-client';
  static const verification = '/verification';
  static const menu = '/menu';
  static const stores = '/stores';
  static const newStore = '/new-store';
  static const summary = '/summary';
  static const products = '/products';
  static const newProduct = '/new-product';
  static const debts = '/debts';
  static const help = '/help';

  /// Salta directo al Resumen de Tienda (pantalla "Inicio"), sin importar
  /// cuántas pantallas haya en el stack de navegación. Se usa desde el
  /// tab "Inicio" de la barra inferior en Fiados, Productos y Ayuda.
  static void goHome(BuildContext context) {
    Navigator.of(context).popUntil((route) => route.settings.name == summary);
  }
}

class FiamasApp extends StatelessWidget {
  const FiamasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiamas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.registerClient: (_) => const RegisterClientScreen(),
        AppRoutes.verification: (_) => const VerificationScreen(),
        AppRoutes.menu: (_) => const MenuScreen(),
        AppRoutes.stores: (_) => const MyStoresScreen(),
        AppRoutes.newStore: (_) => const NewStoreScreen(),
        AppRoutes.summary: (_) => const StoreSummaryScreen(),
        AppRoutes.products: (_) => const ProductsScreen(),
        AppRoutes.newProduct: (_) => const NewProductScreen(),
        AppRoutes.debts: (_) => const DebtsScreen(),
        AppRoutes.help: (_) => const HelpScreen(),
      },
    );
  }
}