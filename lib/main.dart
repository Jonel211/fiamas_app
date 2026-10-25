import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/widgets/main_shell.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/tienda_provider.dart';
import 'features/auth/data/models/tienda_model.dart';
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
import 'features/inventory/domain/inventory_provider.dart'; 
import 'features/menu/presentation/screens/menu_screen.dart';
import 'features/profile/presentation/screens/profile_screen.dart';
import 'features/profile/presentation/screens/edit_profile_screen.dart';
import 'features/notifications/presentation/screens/notifications_screen.dart';
import 'features/stores/presentation/screens/my_stores_screen.dart';
import 'features/stores/presentation/screens/new_store_screen.dart';
import 'features/stores/presentation/screens/edit_store_screen.dart';
import 'features/stores/presentation/screens/store_profile_screen.dart';
import 'features/stores/presentation/screens/delete_store_screen.dart';
import 'features/inventory/presentation/screens/new_product_screen.dart';
import 'features/inventory/presentation/screens/categories_screen.dart';
import 'features/inventory/presentation/screens/new_category_screen.dart';
import 'features/help/presentation/screens/help_screen.dart';
import 'features/help/presentation/screens/about_screen.dart';
import 'features/help/presentation/screens/terms_screen.dart';
import 'features/help/presentation/screens/privacy_screen.dart';
import 'features/customers/presentation/screens/customer_list_screen.dart';
import 'features/customers/presentation/screens/customer_profile_screen.dart';
import 'features/customers/presentation/screens/scoring_history_screen.dart';
import 'features/debts/domain/debt.dart';
import 'features/debts/presentation/screens/debt_detail_screen.dart';
import 'features/debts/presentation/screens/debt_history_screen.dart';
import 'features/debts/presentation/screens/registro_fiado_screen.dart';
import 'features/debts/presentation/screens/nuevo_cliente_screen.dart';
import 'features/debts/presentation/screens/nuevo_cliente_qr_screen.dart';
import 'features/debts/presentation/screens/scanner_view_screen.dart';
import 'features/debts/presentation/screens/finalizar_fiado_screen.dart';
import 'features/menu/presentation/screens/more_options_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/dashboard/presentation/screens/whatsapp_collection_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TiendaProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
      ],
      child: const FiamasApp(),
    ),
  );
}

class AppRoutes {
  AppRoutes._();

  // Autenticación
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

  // Navegación principal
  static const menu = '/menu';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const notifications = '/notifications';
  static const stores = '/stores';
  static const newStore = '/new-store';
  static const summary = '/summary';
  static const whatsappCollection = '/whatsapp-collection';

  // Inventario
  static const newProduct = '/new-product';
  static const categories = '/categories';
  static const newCategory = '/new-category';
  static const editStore = '/edit-store';

  // Fiados
  static const debts = '/debts';
  static const debtDetail = '/debt-detail';
  static const debtHistory = '/debt-history';
  static const registroFiado = '/registro-fiado';
  static const newClient = '/new-client';
  static const newClientQr = '/new-client-qr';
  static const scannerView = '/scanner-view';
  static const finalizarFiado = '/finalizar-fiado';

  // Clientes
  static const customers = '/customers';
  static const customerProfile = '/customer-profile';
  static const scoringHistory = '/scoring-history';

  // Configuración y legales
  static const help = '/help';
  static const about = '/about';
  static const terms = '/terms';
  static const privacy = '/privacy';
  static const moreOptions = '/more-options';
  static const reports = '/reports';
  static const storeProfile = '/store-profile';
  static const deleteStore = '/delete-store';

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
        // Autenticación
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

        // Navegación principal
        AppRoutes.menu: (_) => const MenuScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.stores: (_) => const MyStoresScreen(),
        AppRoutes.newStore: (_) => const NewStoreScreen(),
        AppRoutes.summary: (_) => const MainShellScreen(),
        AppRoutes.whatsappCollection: (_) => const WhatsappCollectionScreen(),

        // Inventario
        AppRoutes.newProduct: (_) => const NewProductScreen(),
        AppRoutes.categories: (_) => const CategoriesScreen(),
        AppRoutes.newCategory: (_) => const NewCategoryScreen(),
        AppRoutes.editStore: (context) {
          final tienda =
              ModalRoute.of(context)!.settings.arguments as TiendaModel;
          return EditStoreScreen(tienda: tienda);
        },

        // Fiados
        AppRoutes.debts: (_) => const MainShellScreen(initialIndex: 2),
        AppRoutes.debtDetail: (context) {
          final debt = ModalRoute.of(context)!.settings.arguments as Debt;
          return DebtDetailScreen(debt: debt);
        },
        AppRoutes.debtHistory: (context) {
          final customer =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return DebtHistoryScreen(customer: customer);
        },
        AppRoutes.registroFiado: (_) => const RegistroFiadoScreen(),
        AppRoutes.newClient: (_) => const NuevoClienteScreen(),
        AppRoutes.newClientQr: (_) => const NuevoClienteQrScreen(),
        AppRoutes.scannerView: (_) => const ScannerViewScreen(),
        AppRoutes.finalizarFiado: (_) => const FinalizarFiadoScreen(),

        // Configuración y legales
        AppRoutes.help: (_) => const HelpScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.terms: (_) => const TermsScreen(),
        AppRoutes.privacy: (_) => const PrivacyScreen(),

        // Clientes
        AppRoutes.customers: (_) => const CustomerListScreen(),
        AppRoutes.customerProfile: (context) {
          final customer =
              ModalRoute.of(context)!.settings.arguments
                  as Map<String, dynamic>;
          return CustomerProfileScreen(customer: customer);
        },
        AppRoutes.scoringHistory: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final customer = args is Map<String, dynamic> ? args : null;
          return ScoringHistoryScreen(customer: customer);
        },

        AppRoutes.moreOptions: (_) => const MoreOptionsScreen(),
        AppRoutes.reports: (_) => const ReportsScreen(),
        AppRoutes.storeProfile: (_) => const StoreProfileScreen(),
        AppRoutes.deleteStore: (_) => const DeleteStoreScreen(),
      },
    );
  }
}
