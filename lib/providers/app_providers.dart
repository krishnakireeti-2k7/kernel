// lib/providers/app_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/workout_service.dart';
import '../main.dart';

// Provider for the Supabase Client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Provider for the WorkoutService (using its singleton)
final workoutServiceProvider = Provider<WorkoutService>((ref) {
  return WorkoutService();
});

// Provider for the authentication state notifier
final authStateNotifierProvider = ChangeNotifierProvider<AuthStateNotifier>((
  ref,
) {
  final supabase = ref.watch(supabaseProvider);
  return AuthStateNotifier(supabase);
});

// Provider to hold the initial sync status (run once at app startup)
final initialSyncProvider = FutureProvider<void>((ref) async {
  final service = ref.watch(workoutServiceProvider);
  final session = ref.watch(authStateNotifierProvider).currentSession;

  // Only run sync if a user is logged in
  if (session != null) {
    await service.syncFromSupabase();
    await service.syncToSupabase();
  }
});
