import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart'; // 💡 Import Provider
import 'package:emecexpo/providers/theme_provider.dart'; // 💡 Import your ThemeProvider
import 'package:emecexpo/model/user_model.dart';
import 'package:emecexpo/my_profile_screen.dart';
import 'package:emecexpo/main.dart';
import 'api_services/auth_api_service.dart';

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

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => WelcomPage(user: loggedInUser),
            ),
                (Route<dynamic> route) => false,
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
    // 💡 Access the theme provider and get the current theme.
    final themeProvider = Provider.of<ThemeProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      // ✅ Use a background color from the theme.
      backgroundColor: theme.whiteColor,
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
                  'assets/EMEC-LOGO.png',
                  height: 120,
                  // ✅ Conditionally color the logo based on the theme.
                  //color: themeProvider.isDark ? theme.whiteColor : null,
                ),
                const SizedBox(height: 48.0),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    // ✅ Use a color from the theme for the icon.
                    prefixIcon: Icon(Icons.email, color: theme.blackColor),
                    // ✅ Use a color from the theme for the label and hint.
                    labelStyle: TextStyle(color: theme.blackColor),
                    hintStyle: TextStyle(color: theme.blackColor.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      // ✅ Use a color from the theme for the border.
                      borderSide: BorderSide(color: theme.blackColor.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: theme.blackColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      // ✅ Use a color from the theme for the focused border.
                      borderSide: BorderSide(color: theme.secondaryColor, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  ),
                  // ✅ Use a color from the theme for the input text.
                  style: TextStyle(color: theme.blackColor),
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
                    // ✅ Use a color from the theme for the icons.
                    prefixIcon: Icon(Icons.lock, color: theme.blackColor),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: theme.blackColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    labelStyle: TextStyle(color: theme.blackColor),
                    hintStyle: TextStyle(color: theme.blackColor.withOpacity(0.5)),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: theme.blackColor.withOpacity(0.5)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: theme.blackColor.withOpacity(0.5)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.0),
                      borderSide: BorderSide(color: theme.secondaryColor, width: 2.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                  ),
                  style: TextStyle(color: theme.blackColor),
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
                    ? Center(child: CircularProgressIndicator(color: theme.secondaryColor))
                    : ElevatedButton(
                  onPressed: _login,
                  style: ElevatedButton.styleFrom(
                    // ✅ Use a color from the theme for the button.
                    backgroundColor: theme.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 18.0,
                      // ✅ Use a color from the theme for the button text.
                      color: theme.whiteColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                TextButton(
                  onPressed: () {
                    print('Forgot Password?');
                  },
                  child: Text(
                    'Forgot Password?',
                    // ✅ Use a color from the theme for the accent text.
                    style: TextStyle(color: theme.secondaryColor),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    print('Register an account');
                  },
                  child: Text(
                    'Don\'t have an account? Register',
                    // ✅ Use a color from the theme for the accent text.
                    style: TextStyle(color: theme.secondaryColor),
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