// lib/app/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/models/workout_template.dart';
import '../features/auth/auth_page.dart';
import '../features/home/home_page.dart';
import '../features/workouts/workout_list_page.dart';
import '../features/workouts/workout_template_page.dart';
import '../features/workouts/workout_session_page.dart';
import '../main.dart';

class AppRouter {
  static GoRouter createRouter({
    required SupabaseClient supabase,
    required Listenable refreshListenable,
  }) {
    return GoRouter(
      initialLocation: '/',
      refreshListenable: refreshListenable,
      routes: [
        // AUTH
        GoRoute(path: '/auth', builder: (_, __) => const AuthPage()),

        // HOME
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),

        // MY ROUTINES LIST
        GoRoute(path: '/workouts', builder: (_, __) => const WorkoutListPage()),

        // CREATE NEW ROUTINE
        GoRoute(
          path: '/workout/template',
          builder: (_, __) => const WorkoutTemplatePage(),
        ),

        // EDIT EXISTING ROUTINE
        GoRoute(
          path: '/workout/template/edit/:id',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            // TODO: Fetch template by ID from service
            return const WorkoutTemplatePage();
          },
        ),

        // START WORKOUT SESSION (with optional template)
        GoRoute(
          path: '/workout/session',
          builder: (_, state) {
            final template = state.extra as WorkoutTemplate?;
            return WorkoutSessionPage(template: template);
          },
        ),

        // EXPLORE (placeholder)
        GoRoute(
          path: '/explore',
          builder:
              (_, __) => Scaffold(
                backgroundColor: Colors.black,
                appBar: AppBar(title: const Text("Explore")),
                body: const Center(
                  child: Text(
                    "Coming soon",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ),
        ),

        // ROOT REDIRECT
        GoRoute(path: '/', redirect: (_, __) => '/home'),
      ],

      redirect: (context, state) {
        final authNotifier = refreshListenable as AuthStateNotifier;
        final session = authNotifier.currentSession;
        final isLoading = authNotifier.isLoading;
        final isOnAuth = state.matchedLocation == '/auth';

        if (isLoading) return null;

        if (session == null) {
          return isOnAuth ? null : '/auth';
        }

        if (isOnAuth) return '/home';

        return null;
      },

      errorBuilder:
          (_, state) => Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Page not found: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ),
    );
  }
}
