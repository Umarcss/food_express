import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:food_express/firebase_options.dart';
import 'package:food_express/pages/cart_page.dart';
import 'package:food_express/pages/delivery_progress_page.dart';
import 'package:food_express/pages/home_page.dart';
import 'package:food_express/pages/login_page.dart';
import 'package:food_express/pages/notifications_page.dart';
import 'package:food_express/pages/order_history_page.dart';
import 'package:food_express/pages/payment_page.dart';
import 'package:food_express/pages/settings_page.dart';
import 'package:food_express/pages/signup_page.dart';
import 'package:food_express/pages/user_profile_page.dart';
import 'package:food_express/providers/auth_provider.dart';
import 'package:food_express/providers/cart_provider.dart';
import 'package:food_express/providers/menu_provider.dart';
import 'package:food_express/providers/notification_provider.dart';
import 'package:food_express/providers/order_provider.dart';
import 'package:food_express/themes/theme_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    firebaseReady = true;
    if (!kIsWeb) {
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;
      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }
  } catch (error) {
    debugPrint('Firebase initialization skipped: $error');
  }

  runApp(FoodExpressApp(firebaseReady: firebaseReady));
}

class FoodExpressApp extends StatelessWidget {
  final bool firebaseReady;

  const FoodExpressApp({
    super.key,
    required this.firebaseReady,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
          create: (_) =>
              AuthProvider(firebaseEnabled: firebaseReady)..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => MenuProvider(firebaseEnabled: firebaseReady)..load(),
        ),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => OrderProvider(firebaseEnabled: firebaseReady),
        ),
        ChangeNotifierProxyProvider<AuthProvider, NotificationProvider>(
          create: (_) => NotificationProvider(firebaseEnabled: firebaseReady),
          update: (_, auth, notifications) {
            final provider = notifications ??
                NotificationProvider(firebaseEnabled: firebaseReady);
            provider.watchForUser(auth.user?.uid);
            return provider;
          },
        ),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Express',
      theme: themeProvider.themeData,
      darkTheme: themeProvider.themeData,
      themeMode: themeProvider.themeMode,
      home: const AuthGate(),
      routes: {
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.signup: (_) => const SignupPage(),
        AppRoutes.home: (_) => const HomePage(),
        AppRoutes.cart: (_) => const CartPage(),
        AppRoutes.checkout: (_) => const PaymentPage(),
        AppRoutes.delivery: (_) => const DeliveryProgressPage(),
        AppRoutes.profile: (_) => const UserProfilePage(),
        AppRoutes.orderHistory: (_) => const OrderHistoryPage(),
        AppRoutes.notifications: (_) => const NotificationsPage(),
        AppRoutes.settings: (_) => const SettingsPage(),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return auth.isAuthenticated ? const HomePage() : const LoginPage();
  }
}

class AppRoutes {
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const delivery = '/delivery';
  static const profile = '/profile';
  static const orderHistory = '/order-history';
  static const notifications = '/notifications';
  static const settings = '/settings';
}
