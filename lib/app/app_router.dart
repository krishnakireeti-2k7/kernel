// lib/app/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kernel/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';
import '../features/workouts/workout_list_page.dart';
import '../features/workouts/workout_template_page.dart';
import '../features/workouts/workout_session_page.dart';

class AppRouter {
  static GoRouter createRouter({
    required SupabaseClient supabase,
    required Listenable refreshListenable,
  }) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable,
      routes: [
        GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/workouts', builder: (_, __) => const WorkoutListPage()),
        GoRoute(
          path: '/workout/template',
          builder: (_, __) => const WorkoutTemplatePage(),
        ),
        GoRoute(
          path: '/workout/template/edit/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            // TODO: fetch template from Hive / service
            return const WorkoutTemplatePage(); // placeholder
          },
        ),
        // <-- dummy page so the router compiles
        GoRoute(
          path: '/workout/session',
          builder: (_, __) => const WorkoutSessionPage(),
        ),
        GoRoute(path: '/', redirect: (_, __) => '/home'),
      ],
      redirect: (context, state) {
        final authNotifier = refreshListenable as AuthStateNotifier;
        final isLoading = authNotifier.isLoading;
        final session = supabase.auth.currentSession;
        final isOnAuth = state.matchedLocation == '/auth';

        if (isLoading) return null;
        if (session == null) return '/auth';
        if (isOnAuth) return '/home';
        return null;
      },
      errorBuilder:
          (_, state) =>
              Scaffold(body: Center(child: Text('Error: ${state.error}'))),
    );
  }
}
