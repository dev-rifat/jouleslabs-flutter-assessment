// lib/core/routes/app_router.dart
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/document/presentation/screens/ducument_editors.dart';
import '../../features/document/presentation/screens/document_list.dart';
import '../../features/home/presentation/screens/home.dart';
import '../../features/starting/view/splash_screen.dart';
import 'app_route.dart';

// Global router instance (kept alive for hot reload)
final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      name: AppRoute.splash,
      builder: (_, __) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login_in',
      name: AppRoute.login,
      builder: (_, __) =>  LoginScreen(),
    ),

    GoRoute(
      path: '/home_screen',
      name: AppRoute.homeScreen,
      builder: (_, __) => const HomeScreen(),
    ),



  ],
);
