import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:family_connect_stable/src/features/auth/presentation/login_screen.dart';
import 'package:family_connect_stable/src/features/auth/presentation/register_screen.dart';
import 'package:family_connect_stable/src/features/home/presentation/home_screen.dart';
import 'package:family_connect_stable/src/features/auth/providers/auth_provider.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoggedIn = authState.isAuthenticated;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      if (!isLoggedIn && !isLoginRoute && !isRegisterRoute) return '/login';
      if (isLoggedIn && (isLoginRoute || isRegisterRoute)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
    ],
  );
});