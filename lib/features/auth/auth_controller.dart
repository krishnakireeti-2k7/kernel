import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController();
});

class AuthController {
  final SupabaseClient _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  // Sign in with email
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    final res = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    await _ensureUserRow();
    return res;
  }

  // Sign up with email
  Future<AuthResponse> signUpWithEmail(
    String email,
    String password, {
    String? displayName,
  }) async {
    final res = await _client.auth.signUp(email: email, password: password);
    await _ensureUserRow(displayName: displayName);
    return res;
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(provider: Provider.google);
    await _ensureUserRow();
  }

  // Sign out
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  // Ensure a row exists in users table
  Future<void> _ensureUserRow({String? displayName}) async {
    final user = _client.auth.currentUser;
    if (user == null) return;

    final response =
        await _client.from('users').select().eq('id', user.id).execute();

    if (response.data == null || (response.data as List).isEmpty) {
      // Insert user row
      await _client.from('users').insert({
        'id': user.id,
        'email': user.email,
        'display_name': displayName ?? user.userMetadata?['full_name'] ?? '',
      }).execute();
    }
  }
}
