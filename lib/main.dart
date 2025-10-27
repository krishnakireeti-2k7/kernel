import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app_router.dart';
import 'app/theme.dart';
import 'features/auth/auth_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://mdijnmmvgxatevyxlyne.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaWpubW12Z3hhdGV2eXhseW5lIiwicm9sZSI6ImFub25uIiwiaWF0IjoxNzYxNDU3ODQzLCJleHAiOjIwNzcwMzM4NDN9.b-rBPczSrUnAQaVSIQ8gGKdrIEP6PpJz2K_obGjGPRM',
  );

  runApp(ProviderScope(child: KernelApp()));
}

class KernelApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kernel',
      theme: AppTheme.lightTheme,
      home: AuthPage(), // start with login page
    );
  }
}
