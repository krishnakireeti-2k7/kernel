import 'package:flutter/material.dart';
import 'auth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthPage extends ConsumerWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Kernel Login')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final res = await authController.signInWithEmail(
                  emailController.text,
                  passwordController.text,
                );
                if (res.user != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Logged in as ${res.user!.email}')),
                  );
                  // Navigate to workout templates page here later
                } else {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Login failed')));
                }
              },
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: () async {
                await authController.signInWithGoogle();
              },
              child: Text('Login with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
