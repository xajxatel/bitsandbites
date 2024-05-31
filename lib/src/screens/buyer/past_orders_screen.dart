import 'package:bitsandbites/src/widgets/buyer_order_tile.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart'; // Import Unicons
import 'package:neopop/neopop.dart'; // Import NeoPop
import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

class PastOrdersScreen extends ConsumerWidget {
  const PastOrdersScreen({Key? key}) : super(key: key);

  Future<void> _showExpensesDialog(
      BuildContext context, WidgetRef ref, String userId) async {
    final expenses =
        await ref.read(orderProvider).calculateBuyerExpenses(userId);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Expenses',
            style: TextStyle(
                color: Colors.blue.shade900, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today: ₹${expenses['today']?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'This Month: ₹${expenses['thisMonth']?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                'Lifetime: ₹${expenses['lifetime']?.toStringAsFixed(2) ?? '0.00'}',
                style: TextStyle(fontSize: 16),
              ),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateChangesProvider).value?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see your past orders.')),
      );
    }

    final pastOrdersStream = ref.watch(buyerOrdersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Past Orders'),
        actions: [
          IconButton(
            icon: const Icon(UniconsLine.wallet),
            onPressed: () {
              _showExpensesDialog(context, ref, userId);
            },
          ),
        ],
      ),
      body: pastOrdersStream.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No past orders yet.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return BuyerOrderTile(order: order);
            },
          );
        },
        loading: () => const Center(child: LoadingIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}
