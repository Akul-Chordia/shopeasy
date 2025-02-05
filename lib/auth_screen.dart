import 'package:flutter/material.dart';
import 'auth_service.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLogin = true;

  void handleAuth() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (isLogin) {
      await _auth.signIn(email, password);
    } else {
      await _auth.signUp(email, password);
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? "Login" : "Register")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: InputDecoration(labelText: "Email")),
            TextField(controller: _passwordController, decoration: InputDecoration(labelText: "Password"), obscureText: true),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? "Login" : "Register"),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? "Create an account" : "Already have an account? Login"),
            ),
          ],
        ),
      ),
    );
  }
}
