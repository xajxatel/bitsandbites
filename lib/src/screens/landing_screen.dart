import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

import 'buyer/auth_screen.dart'; // Import Buyer Auth Screen
import 'seller/seller_login_screen.dart'; // Import Seller Login Screen

class LandingScreen extends StatelessWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          double textFontSize = screenWidth * 0.1; // 10% of the screen width
          double buttonFontSize = screenWidth * 0.05; // 5% of the screen width
          double buttonPaddingHorizontal =
              screenWidth * 0.15; // 15% of the screen width

          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/wallpaper2.jpeg'),
                fit: BoxFit.cover,
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: screenHeight / 1.7,
                  ),
                  Text(
                    'bits and bites',
                    style: GoogleFonts.inconsolata(
                      textStyle: TextStyle(
                        fontSize: textFontSize,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(
                    flex: 2,
                  ),
                  NeoPopButton(
                    color: Colors.white.withOpacity(0.85), // Pearl color
                    onTapUp: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const BuyerAuthScreen()),
                      );
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: buttonPaddingHorizontal,
                        vertical: 15,
                      ),
                      child: Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: buttonFontSize,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const SellerLoginScreen()),
                      );
                    },
                    child: Text(
                      'I am a Vendor',
                      style: TextStyle(
                        fontSize: buttonFontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
