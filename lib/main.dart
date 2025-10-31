// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_page.dart';
import 'features/home/home_page.dart';

class AuthStateNotifier extends ChangeNotifier {
  final SupabaseClient _supabase;
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AuthStateNotifier(this._supabase) {
    // Listen to auth changes
    _supabase.auth.onAuthStateChange.listen((data) {
      _isLoading = false;
      notifyListeners();
    });

    // Trigger session recovery
    _supabase.auth.currentSession;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mdijnmmvgxatevyxlyne.supabase.co',
    anonKey:
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaWpubW12Z3hhdGV2eXhseW5lIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE0NTc4NDMsImV4cCI6MjA3NzAzMzg0M30.b-rBPczSrUnAQaVSIQ8gGKdrIEP6PpJz2K_obGjGPRM'  
  );

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

    _router = GoRouter(
      initialLocation: '/',
      refreshListenable: _authNotifier,
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
        GoRoute(
          path: '/',
          redirect: (context, state) => '/home',
        ),
      ],
      redirect: (context, state) {
        final isLoading = _authNotifier.isLoading;
        final session = _supabase.auth.currentSession;
        final isOnAuth = state.matchedLocation == '/auth';

        if (isLoading) return null; // Wait

        if (session == null) {
          return '/auth';
        }

        if (isOnAuth) {
          return '/home';
        }

        return null;
      },
      errorBuilder:
          (context, state) =>
              Scaffold(body: Center(child: Text('Error: ${state.error}'))),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Kernel',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      routerConfig: _router,
    );
  }
}
