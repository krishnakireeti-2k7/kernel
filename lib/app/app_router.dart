import 'package:go_router/go_router.dart';
import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';

class AppRouter {
  GoRouter get router => GoRouter(
    initialLocation: '/auth',
    routes: [
      GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    ],
  );
}

