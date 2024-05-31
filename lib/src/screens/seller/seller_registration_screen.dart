import 'package:bitsandbites/src/widgets/loading_indicator.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/neopop.dart';
import '../../providers/auth_provider.dart';
import '../../providers/seller_provider.dart';
import 'seller_login_screen.dart';

class SellerRegistrationScreen extends ConsumerStatefulWidget {
  const SellerRegistrationScreen({Key? key}) : super(key: key);

  @override
  _SellerRegistrationScreenState createState() =>
      _SellerRegistrationScreenState();
}

class _SellerRegistrationScreenState
    extends ConsumerState<SellerRegistrationScreen> {
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _upiReceiverNameController = TextEditingController();
  List<String> _selectedCuisines = [];
  bool _loading = false;
  String _selectedAvatar = 'assets/images/avatar1.png';

  final List<String> _cuisineOptions = [
    'Italian',
    'Chinese',
    'North Indian',
    'Sandwich',
    'Rolls',
    'Parathas',
    'Chaat',
    'South Indian',
    'Fast Food',
  ];

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final auth = ref.read(authProvider);
    final sellerService = ref.read(sellerProvider);

    setState(() {
      _loading = true;
    });

    try {
      await auth.createUserWithEmailAndPassword(email, password);
      final user = auth.getCurrentUser();
      if (user != null) {
        await auth.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'A verification email has been sent. Please verify your email and login.')),
        );
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const SellerLoginScreen()),
          (Route<dynamic> route) => false,
        );
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

  Future<void> _saveSellerData(String userId) async {
    final sellerService = ref.read(sellerProvider);

    await sellerService.addSeller(userId, {
      'shopName': _shopNameController.text,
      'ownerName': _ownerNameController.text,
      'location': _locationController.text,
      'phone': _phoneController.text,
      'email': _emailController.text,
      'isOpen': false,
      'cuisines': _selectedCuisines,
      'avatar': _selectedAvatar,
      'upiId': _upiIdController.text,
      'upiReceiverName': _upiReceiverNameController.text,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Register as Vendor'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _shopNameController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _ownerNameController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _locationController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _phoneController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Type of Cuisine',
                    style: GoogleFonts.inconsolata(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Wrap(
                  spacing: 6.0,
                  runSpacing: 6.0,
                  children: _cuisineOptions.map((cuisine) {
                    return FilterChip(
                      label: Text(cuisine),
                      selected: _selectedCuisines.contains(cuisine),
                      onSelected: (isSelected) {
                        setState(() {
                          if (isSelected) {
                            _selectedCuisines.add(cuisine);
                          } else {
                            _selectedCuisines.remove(cuisine);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                SizedBox(height: screenHeight * 0.02),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Select an avatar',
                    style: GoogleFonts.inconsolata(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                Wrap(
                  spacing: 10.0,
                  children: List.generate(7, (index) {
                    final avatarPath = 'assets/images/avatar${index + 1}.png';
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedAvatar = avatarPath;
                        });
                      },
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue.shade900,
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: AssetImage(avatarPath),
                          backgroundColor: _selectedAvatar == avatarPath
                              ? Colors.blue[100]
                              : Colors.white,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _emailController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _passwordController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _upiIdController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'UPI ID',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextField(
                  controller: _upiReceiverNameController,
                  cursorColor: Colors.blue.shade900,
                  decoration: InputDecoration(
                    labelText: 'UPI Receiver Name',
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue.shade900!),
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 16.0,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05),
                NeoPopButton(
                  color: Colors.blue.shade900!,
                  onTapUp: _submit,
                  onTapDown: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 15),
                    child: Text(
                      'Register',
                      style: TextStyle(
                        fontSize: screenWidth * 0.05,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                TextButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SellerLoginScreen()),
                      (Route<dynamic> route) => false,
                    );
                  },
                  child: Text(
                    'I already have an account',
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
