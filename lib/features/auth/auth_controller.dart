import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final supabase.SupabaseClient _client = supabase.Supabase.instance.client;

  supabase.User? get currentUser => _client.auth.currentUser;

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      supabase.Provider.google,
      redirectTo: 'https://mdijnmmvgxatevyxlyne.supabase.co/auth/v1/callback',
    );
    await _ensureUserRow();
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Ensure user row exists
  Future<void> _ensureUserRow({String? displayName}) async {
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
