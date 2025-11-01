// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'features/auth/auth_page.dart';
import 'features/home/home_page.dart';
import 'app/app_router.dart';
import 'core/models/workout_template.dart';

class AuthStateNotifier extends ChangeNotifier {
  final SupabaseClient _supabase;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthStateNotifier(this._supabase) {
    _supabase.auth.onAuthStateChange.listen((_) {
      _isLoading = false;
      notifyListeners();
    });
    _supabase.auth.currentSession;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ---------- Supabase ----------
  await Supabase.initialize(
    url: 'https://mdijnmmvgxatevyxlyne.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaWpubW12Z3hhdGV2eXhseW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0NTc4NDMsImV4cCI6MjA3NzAzMzg0M30.b-rBPczSrUnAQaVSIQ8gGKdrIEP6PpJz2K_obGjGPRM',
  );

  // ---------- Hive ----------
  await Hive.initFlutter();
  Hive.registerAdapter(WorkoutTemplateAdapter());
  Hive.registerAdapter(ExerciseTemplateAdapter());
  await Hive.openBox<WorkoutTemplate>('templates');

  runApp(const ProviderScope(child: KernelApp()));
}

class KernelApp extends ConsumerStatefulWidget {
  const KernelApp({super.key});

  @override
  ConsumerState<KernelApp> createState() => _KernelAppState();
}

class _KernelAppState extends ConsumerState<KernelApp> {
  late final GoRouter _router;
  late final AuthStateNotifier _authNotifier;
  final _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _authNotifier = AuthStateNotifier(_supabase);
    _router = AppRouter.createRouter(
      supabase: _supabase,
      refreshListenable: _authNotifier,
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
