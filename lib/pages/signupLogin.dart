import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pong/pages/avatarSelection.dart';
import 'databaseHandler.dart';
import 'forgetPassword.dart';
import 'menu.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _avatarPath;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void toggleAuthMode() => setState(() => isLogin = !isLogin);

  Future<void> _validateForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (isLogin) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login successful!')),
          );
        } else {
          final userCredential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

          // Save to Firestore
          await FirebaseFirestore.instance
              .collection('users')
              .doc(userCredential.user!.uid)
              .set({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'wins': 0,
            'game_played': 0,
            'loses': 0,
            'draws': 0,
            'level': 0,
            'createdAt': FieldValue.serverTimestamp(),
          });

          // Save to SQLite
          await DatabaseHelper().insertUser({
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'avatar': _avatarPath ?? '',
            'wins': 0,
            'game_played': 0,
            'loses': 0,
            'draws': 0,
            'level': 1,
          });

          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Account created successfully!')),
          );
        }

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => isLogin ? PongScreen(email: _emailController.text.trim()) : AvatarSelectionApp(email: _emailController.text.trim())),
        );
      } on FirebaseAuthException catch (e) {
        String message = 'Authentication failed. Please try again.';
        switch (e.code) {
          case 'weak-password':
            message = 'Password is too weak.';
            break;
          case 'email-already-in-use':
            message = 'Email is already registered.';
            break;
          case 'user-not-found':
            message = 'No user found with this email.';
            break;
          case 'wrong-password':
            message = 'Incorrect password.';
            break;
          case 'invalid-credential':
            message = 'Invalid email or password.';
            break;
          case 'too-many-requests':
            message = 'Too many attempts. Try again later.';
            break;
        }
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1B),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 100),
              const Text("PONG",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF6C63FF))),
              const SizedBox(height: 10),
              const Text("Ready to Play?",
                  style: TextStyle(color: Colors.white60, fontSize: 16)),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildAuthToggle("Login", isLogin),
                        const SizedBox(width: 50),
                        _buildAuthToggle("Sign Up", !isLogin),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Form(
                      key: _formKey,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: isLogin ? _loginForm() : _signUpForm(),
                      ),
                    ),
                    if (isLogin)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => ResetPasswordScreen())),
                          child: const Text("Forgot Password?",
                              style: TextStyle(color: Color(0xFF6C4BF6))),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF6C63FF))
                  : ElevatedButton(
                onPressed: _validateForm,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6C63FF), Color(0xFF8A84FF)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50,
                    child: Text(
                      isLogin ? "Login" : "Sign Up",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text("Or continue with",
                  style: TextStyle(color: Colors.white60, fontSize: 14)),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _socialButton(Icons.g_mobiledata, _signInWithGoogle),
                  const SizedBox(width: 15),
                  _socialButton(Icons.apple, _signInWithApple),
                  const SizedBox(width: 15),
                  _socialButton(Icons.facebook, _signInWithFacebook),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Social Placeholder Functions ---
  Future<void> _signInWithGoogle() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Google Sign-in not implemented yet')),
    );
  }

  Future<void> _signInWithApple() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Apple Sign-in not implemented yet')),
    );
  }

  Future<void> _signInWithFacebook() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Facebook Sign-in not implemented yet')),
    );
  }

  // --- UI Widgets ---
  Widget _buildAuthToggle(String text, bool isActive) => GestureDetector(
    onTap: toggleAuthMode,
    child: Column(
      children: [
        Text(text,
            style: TextStyle(
                fontSize: 16,
                fontWeight:
                isActive ? FontWeight.bold : FontWeight.normal,
                color: Colors.white)),
        if (isActive)
          Container(
              height: 2,
              width: 80,
              color: Colors.white,
              margin: const EdgeInsets.only(top: 4)),
      ],
    ),
  );

  Widget _loginForm() => Column(
    key: const ValueKey('login'),
    children: [
      _customTextField(
          icon: Icons.email,
          hint: "Email",
          controller: _emailController,
          validator: (v) =>
          EmailValidator.validate(v ?? "") ? null : "Enter valid email"),
      const SizedBox(height: 10),
      _customTextField(
          icon: Icons.lock,
          hint: "Password",
          controller: _passwordController,
          validator: (v) =>
          (v?.length ?? 0) >= 6 ? null : "Password must be 6+ characters",
          isPassword: true),
    ],
  );

  Widget _signUpForm() => Column(
    key: const ValueKey('signup'),
    children: [
      _customTextField(
          icon: Icons.person,
          hint: "Name",
          controller: _nameController,
          validator: (v) => (v?.length ?? 0) >= 3 &&
              RegExp(r'^[a-zA-Z ]+$').hasMatch(v ?? "")
              ? null
              : "Enter valid name"),
      const SizedBox(height: 10),
      _customTextField(
          icon: Icons.email,
          hint: "Email",
          controller: _emailController,
          validator: (v) =>
          EmailValidator.validate(v ?? "") ? null : "Enter valid email"),
      const SizedBox(height: 10),
      _customTextField(
          icon: Icons.lock,
          hint: "Password",
          controller: _passwordController,
          validator: (v) =>
          (v?.length ?? 0) >= 6 ? null : "Password must be 6+ characters",
          isPassword: true),
    ],
  );

  Widget _customTextField({
    required IconData icon,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool isPassword = false,
  }) =>
      TextFormField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.white),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: const Color(0xFF2E2F3F),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none)),
        validator: validator,
      );

  Widget _socialButton(IconData icon, VoidCallback onPressed) => InkWell(
    onTap: onPressed,
    child: CircleAvatar(
      radius: 25,
      backgroundColor: Colors.white12,
      child: Icon(icon, color: Colors.white, size: 30),
    ),
  );
}
