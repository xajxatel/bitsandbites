import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:bitsandbites/src/widgets/rectactangular_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../landing_screen.dart';
import 'edit_profile_screen.dart'; // Import the EditProfileScreen
import 'package:unicons/unicons.dart'; // Import Unicons
import 'package:neopop/neopop.dart'; // Import NeoPop
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

class SellerSettingsScreen extends ConsumerWidget {
  const SellerSettingsScreen({Key? key}) : super(key: key);

  Future<void> _showEarningsDialog(
      BuildContext context, WidgetRef ref, String userId) async {
    final earnings =
        await ref.read(sellerProvider).calculateSellerEarnings(userId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Earnings',
            style: TextStyle(
                color: Colors.blue.shade900, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today: ₹${earnings['today']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 3),
              Text(
                  'This Month: ₹${earnings['thisMonth']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 3),
              Text(
                  'Lifetime: ₹${earnings['lifetime']?.toStringAsFixed(2) ?? '0.00'}',
                  style: const TextStyle(fontSize: 16)),
            ],
          ),
          actions: [
            NeoPopButton(
              color: Colors.blue.shade900!,
              onTapUp: () {
                Navigator.of(context).pop();
              },
              onTapDown: () {},
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text(
                  'Ok',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Out?',
              style: TextStyle(
                  color: Colors.blue.shade900, fontWeight: FontWeight.bold)),
          content: const Text(
            'You will be redirected to the landing screen',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:  Text('Cancel',
                  style: TextStyle(color: Colors.blue.shade900)),
            ),
            TextButton(
              onPressed: () {
                ref.read(authProvider).signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const LandingScreen()),
                );
              },
              child:
                  const Text('Sign Out', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateChangesProvider).value?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    final sellerStream = ref.watch(sellerDocProvider(userId));
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(UniconsLine.wallet),
            onPressed: () {
              _showEarningsDialog(context, ref, userId);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            sellerStream.when(
              data: (seller) {
                return ListTile(
                  leading: const Icon(UniconsLine.store), // Use Unicons
                  title: const Text('Store Status'),
                  trailing: RectangularSwitch(
                    value: seller.isOpen,
                    onChanged: (value) async {
                      await ref
                          .read(sellerProvider)
                          .updateSellerStatus(userId, value);
                    },
                  ),
                );
              },
              loading: () => const LoadingIndicator(),
              error: (error, stack) => ListTile(
                leading: const Icon(UniconsLine.exclamation_circle,
                    color: Colors.red), // Use Unicons
                title: Text('Error: $error'),
              ),
            ),
            ListTile(
              leading: const Icon(UniconsLine.pen), // Use Unicons
              title: const Text('Edit Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(
                        sellerId: userId), // Navigate to the EditProfileScreen
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(UniconsLine.signout), // Use Unicons
              title: const Text('Logout'),
              onTap: () {
                _showSignOutDialog(context, ref);
              },
            ),
          ],
        ),
      ),
    );
  }
}
