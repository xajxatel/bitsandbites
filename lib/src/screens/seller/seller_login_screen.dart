import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/neopop.dart';
import 'seller_home_screen.dart';
import 'seller_registration_screen.dart';
import '../../providers/auth_provider.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerLoginScreen extends ConsumerStatefulWidget {
  const SellerLoginScreen({Key? key}) : super(key: key);

  @override
  _SellerLoginScreenState createState() => _SellerLoginScreenState();
}

class _SellerLoginScreenState extends ConsumerState<SellerLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _submit() async {
    // Hide the keyboard
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final auth = ref.read(authProvider);

    setState(() {
      _loading = true;
    });

    try {
      await auth.signInWithEmailAndPassword(email, password);
      final user = auth.getCurrentUser();
      if (user != null && user.emailVerified) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SellerHomeScreen()),
          (Route<dynamic> route) => false,
        );
      } else {
        await auth.signOut();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please verify your email before signing in.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Authentication Error')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _resetPassword() {
    final email = _emailController.text.trim();
    if (email.isNotEmpty) {
      ref.read(authProvider).sendPasswordResetEmail(email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Login as Vendor'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                Image.asset(
                  'assets/images/login.png',
                  height: screenHeight * 0.27,
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'Login',
                  style: GoogleFonts.inconsolata(
                    fontSize: screenWidth * 0.1,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                TextField(
                  controller: _emailController,
                  cursorColor: Colors.blue.shade900, // Change cursor color
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _passwordController,
                  cursorColor: Colors.blue.shade900, // Change cursor color
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.05),
                SizedBox(
                  width: screenWidth * 0.4,
                  child: NeoPopButton(
                    color: Colors.blue.shade900!,
                    onTapUp: _submit,
                    onTapDown: () {},
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Login',
                            style: TextStyle(
                              fontSize: screenWidth * 0.05,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextButton(
                  onPressed: _resetPassword,
                  child: Text(
                    'Forgot Password?',
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const SellerRegistrationScreen()),
                    );
                  },
                  child: Text(
                    "I don't have an account",
                    style: TextStyle(
                      fontSize: screenWidth * 0.04,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Container(
              color: Colors.blue.shade900.withOpacity(0.5),
              child: const Center(child: LoadingIndicator()),
            ),
        ],
      ),
    );
  }
}
