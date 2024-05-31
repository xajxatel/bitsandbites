import 'package:bitsandbites/src/widgets/loading_indicator.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

import '../../providers/auth_provider.dart';
import 'buyer_main_screen.dart';

class BuyerAuthScreen extends ConsumerStatefulWidget {
  const BuyerAuthScreen({Key? key}) : super(key: key);

  @override
  _BuyerAuthScreenState createState() => _BuyerAuthScreenState();
}

class _BuyerAuthScreenState extends ConsumerState<BuyerAuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController(); // New controller for name
  bool _isLogin = true;
  bool _loading = false;

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim(); // Get name
    final auth = ref.read(authProvider);

    // Hide the keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _loading = true;
    });

    try {
      if (_isLogin) {
        await auth.signInWithEmailAndPassword(email, password);
        await auth.reloadUser();
        final user = auth.getCurrentUser();
        if (user != null && user.emailVerified) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const BuyerMainScreen()),
            (Route<dynamic> route) => false,
          );
        } else {
          await auth.signOut();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Please verify your email before signing in.')),
          );
        }
      } else {
        if (email.endsWith('@hyderabad.bits-pilani.ac.in')) {
          await auth.createUserWithEmailAndPassword(email, password);
          await auth.sendEmailVerification();

          // Save buyer info to Firestore
          final user = auth.getCurrentUser();
          if (user != null) {
            await FirebaseFirestore.instance
                .collection('buyers')
                .doc(user.uid)
                .set({
              'name': name,
              'email': email,
            });
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    'A verification email has been sent. Please verify your email.')),
          );
          setState(() {
            _isLogin = true;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Please use a valid BITS Hyderabad email address')),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Authentication Error')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Password reset email sent')));
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please enter your email')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: screenHeight * 0.1),
                  Image.asset(
                    _isLogin
                        ? 'assets/images/login.png'
                        : 'assets/images/signup.png',
                    height: screenHeight * 0.27,
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  Text(
                    _isLogin ? 'Login' : 'Sign Up',
                    style: GoogleFonts.inconsolata(
                      fontSize: screenWidth * 0.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  if (!_isLogin) // Show name field only for sign up
                    Column(
                      children: [
                        TextField(
                          controller: _nameController,
                          cursorColor:
                              Colors.blue.shade900, // Change cursor color
                          decoration: InputDecoration(
                            labelText: 'Name',
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue.shade900!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue.shade900!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: Colors.blue.shade900!),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 16.0,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                      ],
                    ),
                  TextField(
                    controller: _emailController,
                    cursorColor: Colors.blue.shade900, // Change cursor color
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                            color:
                                Colors.blue.shade900!), // Change border color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
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
                        borderSide: BorderSide(
                            color:
                                Colors.blue.shade900!), // Change border color
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue.shade900!),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 16.0,
                      ),
                    ),
                    obscureText: true,
                  ),
                  SizedBox(height: screenHeight * 0.05),
                  SizedBox(
                    width: screenWidth * 0.6,
                    child: NeoPopButton(
                      color: Colors.blue.shade900!,
                      onTapUp: () => _submit(),
                      onTapDown: () {},
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isLogin ? 'Login' : 'Sign Up',
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
                    onPressed: () {
                      if (_isLogin) {
                        _resetPassword();
                      } else {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      }
                    },
                    child: Text(
                      _isLogin
                          ? 'Forgot Password?'
                          : 'I already have an account',
                      style: TextStyle(
                        fontSize: screenWidth * 0.04,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ),
                  if (_isLogin)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = false;
                        });
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
          ),
          if (_loading)
            const LoadingIndicator(), // Show the LoadingScreen when loading
        ],
      ),
    );
  }
}
