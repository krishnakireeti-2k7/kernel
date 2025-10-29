// lib/main.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_page.dart';
import 'features/home/home_page.dart';

/// A notifier that rebuilds GoRouter when the auth state changes.
class StreamChangeNotifier extends ChangeNotifier {
  final Stream _stream;
  late final StreamSubscription _sub;

  StreamChangeNotifier(this._stream) {
    _sub = _stream.listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mdijnmmvgxatevyxlyne.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaWpubW12Z3hhdGV2eXhseW5lIiwicm9sZSI6ImFub25uIiwiaWF0IjoxNzYxNDU3ODQzLCJleHAiOjIwNzcwMzM4NDN9.b-rBPczSrUnAQaVSIQ8gGKdrIEP6PpJz2K_obGjGPRM',
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
  final _supabase = Supabase.instance.client;
  late final StreamChangeNotifier _authNotifier;

  @override
  void initState() {
    super.initState();
    _authNotifier = StreamChangeNotifier(_supabase.auth.onAuthStateChange);

    _router = GoRouter(
      initialLocation: '/auth',
      refreshListenable: _authNotifier,
      routes: [
        GoRoute(path: '/auth', builder: (context, state) => const AuthPage()),
        GoRoute(path: '/home', builder: (context, state) => const HomePage()),
      ],
      redirect: (context, state) {
        final session = _supabase.auth.currentSession;
        final loggingIn = state.matchedLocation == '/auth';

        // 🔥 Core logic: after login redirect to /home
        if (session == null) {
          return loggingIn ? null : '/auth';
        } else {
          return loggingIn ? '/home' : null;
        }
      },
      errorBuilder:
          (context, state) =>
              Scaffold(body: Center(child: Text('Error: ${state.error}'))),
    );
  }

  @override
  void dispose() {
    _authNotifier.dispose();
    super.dispose();
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
