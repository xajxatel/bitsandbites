import 'package:bitsandbites/src/widgets/loading_indicator.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';

import '../../providers/auth_provider.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/outlet_tile.dart';
import '../landing_screen.dart';
import 'outlet_menu_screen.dart';

class BuyerHomeScreen extends ConsumerWidget {
  const BuyerHomeScreen({Key? key}) : super(key: key);

  Future<void> _showSignOutDialog(BuildContext context, WidgetRef ref) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sign Out?',
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          content: const Text('You will be redirected to the landing screen',
              style: TextStyle(fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
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
    final sellersStream = ref.watch(allSellersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('BITS Outlets'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(UniconsLine.signout), // Use Unicons
            onPressed: () {
              _showSignOutDialog(context, ref);
            },
          ),
        ],
      ),
      body: sellersStream.when(
        data: (sellers) {
          if (sellers.isEmpty) {
            return const Center(child: Text('No food outlets available.'));
          }
          return ListView.builder(
            itemCount: sellers.length,
            itemBuilder: (context, index) {
              final seller = sellers[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OutletMenuScreen(
                        sellerId: seller.id,
                        sellerName: seller.shopName,
                      ),
                    ),
                  );
                },
                child: OutletTile(
                  sellerId: seller.id,
                  shopName: seller.shopName,
                  isOpen: seller.isOpen,
                  cuisines: seller.cuisines.join(', '),
                  phone: seller.phone,
                  avatar: seller.avatar, // Pass avatar to OutletTile
                ),
              );
            },
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
