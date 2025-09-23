import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:emecexpo/model/user_model.dart';
// import 'package:emecexpo/home_screen.dart'; // <--- REMOVED: This was the old direct target
import 'package:emecexpo/my_profile_screen.dart'; // Keep if used for other purposes

// IMPORT THE FILE WHERE WELCOMPAGE IS DEFINED (WHICH IS MAIN.DART IN YOUR CASE)
import 'package:emecexpo/main.dart'; // <--- ADDED: To access WelcomPage

import 'api_services/auth_api_service.dart'; // Your authentication service

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final AuthApiService authService = AuthApiService();
      final Map<String, dynamic> result = await authService.loginUser(
        _emailController.text,
        _passwordController.text,
      );

      if (result['success'] == true) {
        final String? authToken = result['token'];
        final User? loggedInUser = result['user'];

        if (authToken != null && loggedInUser != null) {
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('authToken', authToken);
          await prefs.setString('currentUserJson', json.encode(loggedInUser.toJson()));

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Login Successful!')),
          );

          // --- CRITICAL CHANGE HERE ---
          // Navigate to WelcomPage (your main app shell that has the bottom nav)
          // and clear the entire navigation stack, making WelcomPage the new root.
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              // Now we build WelcomPage, which lives in main.dart
              builder: (context) => WelcomPage(user: loggedInUser),
            ),
                (Route<dynamic> route) => false, // This predicate removes all previous routes
          );
        } else {
          _showErrorDialog(result['message'] ?? 'Login Failed: Missing token or user data.');
        }
      } else {
        _showErrorDialog(result['message'] ?? 'An unknown error occurred during login.');
      }
    } catch (e) {
      print('Error calling login service: $e');
      _showErrorDialog('An unexpected client-side error occurred. Please try again.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Login Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Okay'),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // Logo or app icon
                Image.asset(
                  'assets/EMEC-LOGO.png', // Ensure this asset path is correct
                  height: 120,
                ),
                const SizedBox(height: 48.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16.0),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters long';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24.0),
                _isLoading
                    ? const Center(child: CircularProgressIndicator()) // <--- FIX IS HERE
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff261350), // Your primary color
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 18.0, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    // TODO: Implement Forgot Password navigation
                    print('Forgot Password?');
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordScreen()));
                  },
                  child: const Text(
                    'Forgot Password?',
                    style: TextStyle(color: Color(0xff00c1c1)), // Your accent color
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Implement Register navigation
                    print('Register an account');
                    // Example: Navigator.push(context, MaterialPageRoute(builder: (context) => RegistrationScreen()));
                  },
                  child: const Text(
                    'Don\'t have an account? Register',
                    style: TextStyle(color: Color(0xff00c1c1)), // Your accent color
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}