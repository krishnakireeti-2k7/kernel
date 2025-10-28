import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/app_router.dart';
import 'app/theme.dart';
import 'features/auth/auth_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mdijnmmvgxatevyxlyne.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaWpubW12Z3hhdGV2eXhseW5lIiwicm9sZSI6ImFub25uIiwiaWF0IjoxNzYxNDU3ODQzLCJleHAiOjIwNzcwMzM4NDN9.b-rBPczSrUnAQaVSIQ8gGKdrIEP6PpJz2K_obGjGPRM',
  );

  runApp(const ProviderScope(child: KernelApp()));
}

class KernelApp extends ConsumerWidget {
  const KernelApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabase = Supabase.instance.client;

    return MaterialApp(
      title: 'Kernel',
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<AuthState>(
        stream: supabase.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = supabase.auth.currentSession;
          if (session == null) {
            // Not logged in
            return AuthPage();
          } else {
            // Logged in → you can replace with your home screen later
            return const Scaffold(
              body: Center(
                child: Text('Logged In ✅', style: TextStyle(fontSize: 24)),
              ),
            );
          }
        },
      ),
    );
  }
}
