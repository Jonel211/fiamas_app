import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/register_client_screen.dart';
import 'features/auth/presentation/screens/verification_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/reset_code_screen.dart';
import 'features/auth/presentation/screens/new_password_screen.dart';
import 'features/menu/presentation/screens/menu_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/stores/presentation/screens/my_stores_screen.dart';
import 'features/stores/presentation/screens/new_store_screen.dart';
import 'features/stores/presentation/screens/edit_store_screen.dart';
import 'features/inventory/presentation/screens/new_product_screen.dart';
import 'features/inventory/presentation/screens/categories_screen.dart';
import 'features/inventory/presentation/screens/new_category_screen.dart';
import 'features/help/presentation/screens/help_screen.dart';
import 'features/help/presentation/screens/about_screen.dart';
import 'features/help/presentation/screens/terms_screen.dart';
import 'features/help/presentation/screens/privacy_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const FiamasApp(),
    ),
  );
}

class AppRoutes {
  AppRoutes._();
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const register = '/register';
  static const registerClient = '/register-client';
  static const verification = '/verification';
  static const changePassword = '/change-password';
  static const forgotPassword = '/forgot-password';
  static const resetCode = '/reset-code';
  static const newPassword = '/new-password';
  static const menu = '/menu';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const notifications = '/notifications';
  static const stores = '/stores';
  static const newStore = '/new-store';
  static const summary = '/summary';
  static const newProduct = '/new-product';
  static const categories = '/categories';
  static const newCategory = '/new-category';
  static const editStore = '/edit-store';
  static const debts = '/debts';
  static const help = '/help';
  static const about = '/about';
  static const terms = '/terms';
  static const privacy = '/privacy';

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
        AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
        AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
        AppRoutes.resetCode: (_) => const ResetCodeScreen(),
        AppRoutes.newPassword: (_) => const NewPasswordScreen(),
        AppRoutes.menu: (_) => const MenuScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.stores: (_) => const MyStoresScreen(),
        AppRoutes.newStore: (_) => const NewStoreScreen(),
        AppRoutes.summary: (_) => const MainShellScreen(),
        AppRoutes.newProduct: (_) => const NewProductScreen(),
        AppRoutes.categories: (_) => const CategoriesScreen(),
        AppRoutes.newCategory: (_) => const NewCategoryScreen(),
        AppRoutes.editStore: (_) => const EditStoreScreen(),
        // AppRoutes.debts: (_) => const DebtsScreen(),
        AppRoutes.help: (_) => const HelpScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.terms: (_) => const TermsScreen(),
        AppRoutes.privacy: (_) => const PrivacyScreen(),
      },
    );
  }
}