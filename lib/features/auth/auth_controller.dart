import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:flutter/material.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  supabase.User? get currentUser => _client.auth.currentUser;

  /// Google Sign-In
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      supabase.OAuthProvider.google,
      redirectTo: 'io.supabase.flutterdemo://login-callback/',
      queryParams: {'prompt': 'select_account'},
    );

    // Auto-create user row after successful login
    await ensureUserRow();
  }

  /// Sign Out
  Future<void> signOut(BuildContext context) async {
    await _client.auth.signOut();

    // Navigate back to AuthPage
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
    }
  }

  /// Ensure user exists in 'users' table
  Future<void> ensureUserRow({String? displayName}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final response =
        await _client.from('users').select().eq('id', user.id).maybeSingle();

    if (response == null) {
      await _client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'display_name':
            displayName ??
            user.userMetadata?['full_name'] ??
            user.email?.split('@').first ??
            '',
      });
    }
  }
}
