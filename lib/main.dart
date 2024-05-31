import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'src/screens/landing_screen.dart';
import 'src/screens/buyer/buyer_main_screen.dart';
import 'src/screens/seller/seller_home_screen.dart';
import 'src/providers/auth_provider.dart';
import 'firebase_options.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: 'Bits and Bites',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.inconsolataTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: authState.when(
        data: (user) {
          if (user == null) {
            return const LandingScreen();
          } else {
            final isSellerAsyncValue = ref.watch(isSellerProvider);
            final isBuyerAsyncValue = ref.watch(isBuyerProvider);
            return isSellerAsyncValue.when(
              data: (isSeller) {
                if (isSeller) {
                  return const SellerHomeScreen();
                } else {
                  return isBuyerAsyncValue.when(
                    data: (isBuyer) {
                      if (isBuyer) {
                        return const BuyerMainScreen();
                      } else {
                        return const LandingScreen();
                      }
                    },
                    loading: () => const LoadingIndicator(),
                    error: (error, stackTrace) => const LandingScreen(),
                  );
                }
              },
              loading: () => const LoadingIndicator(),
              error: (error, stackTrace) => const LandingScreen(),
            );
          }
        },
        loading: () => const LoadingIndicator(),
        error: (error, stackTrace) => const LandingScreen(),
      ),
    );
  }
}
