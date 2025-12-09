// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app/app_router.dart';
import 'core/models/workout_template.dart';
import 'core/models/routine.dart';
import 'providers/app_providers.dart';

// AuthStateNotifier class remains the same
class AuthStateNotifier extends ChangeNotifier {
  final SupabaseClient _supabase;
  bool _isLoading = true;
  Session? _currentSession;

  bool get isLoading => _isLoading;
  Session? get currentSession => _currentSession;

  AuthStateNotifier(this._supabase) {
    _currentSession = _supabase.auth.currentSession;
    _isLoading = false;

    _supabase.auth.onAuthStateChange.listen((data) {
      _currentSession = data.session;
      _isLoading = false;
      notifyListeners();
    });
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mdijnmmvgxatevyxlyne.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaWpubW12Z3hhdGV2eXhseW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0NTc4NDMsImV4cCI6MjA3NzAzMzg0M30.b-rBPczSrUnAQaVSIQ8gGKdrIEP6PpJz2K_obGjGPRM',

    realtimeClientOptions: const RealtimeClientOptions(),

    // The simplified AuthOptions to prevent parameter errors in recent Supabase versions
    authOptions: const FlutterAuthClientOptions(),
  );

  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutTemplateAdapter());
  Hive.registerAdapter(ExerciseTemplateAdapter());
  Hive.registerAdapter(RoutineAdapter());
  await Hive.openBox<WorkoutTemplate>('templates');
  await Hive.openBox<Routine>('routines');

  runApp(const ProviderScope(child: KernelApp()));
}

// KernelApp and _KernelAppState remain the same
class KernelApp extends ConsumerStatefulWidget {
  const KernelApp({super.key});
  @override
  ConsumerState<KernelApp> createState() => _KernelAppState();
}

class _KernelAppState extends ConsumerState<KernelApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final authNotifier = ref.read(authStateNotifierProvider);
    _router = AppRouter.createRouter(
      supabase: Supabase.instance.client,
      refreshListenable: authNotifier,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kernel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(backgroundColor: Colors.black),
      ),
      routerConfig: _router,
    );
  }
}
