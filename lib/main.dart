import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'core/constants/app_colors.dart';
import 'core/navigation/app_header_observer.dart';
import 'core/network/dio_client.dart';
import 'core/providers/app_bar_controller.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_header.dart';
import 'core/widgets/main_shell.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/auth/presentation/providers/tienda_provider.dart';
import 'features/auth/data/models/tienda_model.dart';
import 'features/customers/presentation/providers/cliente_provider.dart';
import 'features/customers/data/models/cliente_model.dart';
import 'features/auth/presentation/screens/splash_screen.dart';
import 'features/auth/presentation/screens/welcome_screen.dart';
import 'features/auth/presentation/screens/verification_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
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
import 'features/customers/presentation/screens/customer_profile_screen.dart';
import 'features/customers/presentation/screens/scoring_history_screen.dart';
import 'features/debts/domain/debt.dart';
import 'features/debts/presentation/screens/debt_detail_multiple_screen.dart';
import 'features/debts/presentation/screens/debt_history_screen.dart';
import 'features/debts/presentation/screens/registro_fiado_screen.dart';
import 'features/debts/presentation/screens/nuevo_cliente_screen.dart';
import 'features/debts/presentation/screens/nuevo_cliente_qr_screen.dart';
import 'features/debts/presentation/screens/scanner_view_screen.dart';
import 'features/debts/presentation/screens/finalizar_fiado_screen.dart';
import 'features/reports/presentation/screens/reports_screen.dart';
import 'features/dashboard/presentation/screens/whatsapp_collection_screen.dart';

import 'firebase_options.dart';

/// Permite navegar sin contexto (por ejemplo, al vencer la sesión).
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Observador global de rutas para detectar cuando se regresa a una pantalla
final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

Future<void> main() async {
  // Si el servidor rechaza el token, se cierra la sesión y se va al login.
  DioClient.onUnauthorized = _cerrarSesionPorTokenVencido;

  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TiendaProvider()),
        ChangeNotifierProxyProvider2<AuthProvider, TiendaProvider, InventoryProvider>(
          create: (_) => InventoryProvider(),
          update: (_, auth, tienda, inventory) {
            final inv = inventory ?? InventoryProvider();
            final token = auth.token;
            final tiendaId = tienda.tiendaSeleccionadaId;
            if (token == null || tiendaId == null) {
              inv.reset();
            } else {
              inv.updateTiendaContext(token, tiendaId);
            }
            return inv;
          },
        ),
        ChangeNotifierProvider(create: (_) => ClienteProvider()),
        ChangeNotifierProvider(create: (_) => AppBarController()),
      ],
      child: const FiamasApp(),
    ),
  );
}

Future<void> _cerrarSesionPorTokenVencido() async {
  final context = navigatorKey.currentContext;
  if (context == null) {
    DioClient.resetUnauthorized();
    return;
  }

  final tienda = context.read<TiendaProvider>();
  final auth = context.read<AuthProvider>();

  await tienda.limpiarSesion();
  await auth.logout();

  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    AppRoutes.welcome,
    (route) => false,
    arguments: 'login',
  );

  final messenger = ScaffoldMessenger.maybeOf(navigatorKey.currentContext ?? context);
  messenger?.showSnackBar(
    const SnackBar(content: Text('Tu sesión venció. Inicia sesión de nuevo.')),
  );

  DioClient.resetUnauthorized();
}

class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const welcome = '/welcome';
  static const verification = '/verification';
  static const changePassword = '/change-password';

  static const menu = '/menu';
  static const profile = '/profile';
  static const editProfile = '/edit-profile';
  static const notifications = '/notifications';
  static const stores = '/stores';
  static const newStore = '/new-store';
  static const summary = '/summary';
  static const whatsappCollection = '/whatsapp-collection';

  static const newProduct = '/new-product';
  static const categories = '/categories';
  static const newCategory = '/new-category';
  static const editStore = '/edit-store';

  static const debts = '/debts';
  static const debtDetail = '/debt-detail';
  static const debtHistory = '/debt-history';
  static const registroFiado = '/registro-fiado';
  static const newClient = '/new-client';
  static const newClientQr = '/new-client-qr';
  static const scannerView = '/scanner-view';
  static const finalizarFiado = '/finalizar-fiado';

  static const customers = '/customers';
  static const customerProfile = '/customer-profile';
  static const scoringHistory = '/scoring-history';

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

  static void goToLogin(BuildContext context) {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(welcome, (route) => false, arguments: 'login');
  }
}

class FiamasApp extends StatelessWidget {
  const FiamasApp({super.key});

  static final AppHeaderObserver _headerObserver = AppHeaderObserver();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fiamas',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      navigatorKey: navigatorKey,
      initialRoute: AppRoutes.splash,
      navigatorObservers: [_headerObserver, routeObserver], // Agregamos el routeObserver a la lista 
      builder: (context, child) {
        final content = child ?? const SizedBox.shrink();

        return Consumer<AppBarController>(
          builder: (context, controller, _) {
            final config = controller.activeConfig;
            final showHeader = config != null && config.visible;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showHeader) _buildHeader(config) else const SizedBox.shrink(),
                Expanded(
                  child: MediaQuery.removePadding(
                    context: context,
                    removeTop: showHeader,
                    child: content,
                  ),
                ),
              ],
            );
          },
        );
      },
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.welcome: (_) => const WelcomeScreen(),
        AppRoutes.verification: (_) => const VerificationScreen(),
        AppRoutes.changePassword: (_) => const ChangePasswordScreen(),
        
        AppRoutes.menu: (_) => const MenuScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.editProfile: (_) => const EditProfileScreen(),
        AppRoutes.notifications: (_) => const NotificationsScreen(),
        AppRoutes.stores: (_) => const MyStoresScreen(),
        AppRoutes.newStore: (_) => const NewStoreScreen(),
        AppRoutes.summary: (_) => const MainShellScreen(),
        AppRoutes.whatsappCollection: (_) => const WhatsappCollectionScreen(),
        AppRoutes.newProduct: (_) => const NewProductScreen(),
        AppRoutes.categories: (_) => const CategoriesScreen(),
        AppRoutes.newCategory: (_) => const NewCategoryScreen(),
        AppRoutes.editStore: (context) {
          final tienda = ModalRoute.of(context)!.settings.arguments as TiendaModel;
          return EditStoreScreen(tienda: tienda);
        },
        AppRoutes.debts: (_) => const MainShellScreen(initialIndex: 2),
        AppRoutes.debtDetail: (context) {
          final debt = ModalRoute.of(context)!.settings.arguments as Debt;
          return DebtDetailMultipleScreen(
            customer: {'name': debt.customerName, 'phone': debt.phone},
            debts: [debt],
          );
        },
        AppRoutes.debtHistory: (context) {
          final customer = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DebtHistoryScreen(customer: customer);
        },
        AppRoutes.registroFiado: (_) => const RegistroFiadoScreen(),
        AppRoutes.newClient: (context) {
          final phone = ModalRoute.of(context)?.settings.arguments as String?;
          return NuevoClienteScreen(initialPhone: phone);
        },
        AppRoutes.newClientQr: (_) => const NuevoClienteQrScreen(),
        AppRoutes.scannerView: (context) {
          final cliente = ModalRoute.of(context)!.settings.arguments as ClienteModel;
          return ScannerViewScreen(cliente: cliente);
        },
        AppRoutes.finalizarFiado: (_) => const FinalizarFiadoScreen(),
        AppRoutes.help: (_) => const HelpScreen(),
        AppRoutes.about: (_) => const AboutScreen(),
        AppRoutes.terms: (_) => const TermsScreen(),
        AppRoutes.privacy: (_) => const PrivacyScreen(),
        AppRoutes.customers: (_) => const MainShellScreen(initialIndex: 3),
        AppRoutes.customerProfile: (context) {
          final cliente = ModalRoute.of(context)!.settings.arguments as ClienteModel;
          return CustomerProfileScreen(customer: cliente);
        },
        AppRoutes.scoringHistory: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final customer = args is Map<String, dynamic> ? args : null;
          return ScoringHistoryScreen(customer: customer);
        },
        AppRoutes.moreOptions: (_) => const MainShellScreen(initialIndex: 4),
        AppRoutes.reports: (_) => const ReportsScreen(),
        AppRoutes.storeProfile: (_) => const StoreProfileScreen(),
        AppRoutes.deleteStore: (_) => const DeleteStoreScreen(),
      },
    );
  }

  Widget _buildHeader(HeaderConfig config) {
    return Material(
      color: AppColors.teal,
      child: DefaultTextStyle(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          decoration: TextDecoration.none,
        ),
        child: AppHeader(
          title: config.title,
          subtitle: config.subtitle,
          showBack: config.showBack,
          onBack: config.onBack,
          leading: config.leading,
          centerTitle: config.centerTitle,
          actions: config.actions,
        ),
      ),
    );
  }
}