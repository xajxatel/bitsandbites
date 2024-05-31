import 'package:bitsandbites/src/providers/seller_provider.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:bitsandbites/src/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import '../../models/order_model.dart';

class SellerOrderHistoryScreen extends ConsumerWidget {
  const SellerOrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(authStateChangesProvider).value?.uid;

    if (userId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to see orders.')),
      );
    }

    final ordersStream = ref.watch(sellerOrdersProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Old Orders'),
      ),
      body: ordersStream.when(
        data: (orders) {
          // Filter orders that are not from today
          final today = DateTime.now();
          final nonTodayOrders = orders.where((order) {
            final orderDate = order.timestamp.toDate();
            return orderDate.year != today.year ||
                orderDate.month != today.month ||
                orderDate.day != today.day;
          }).toList();

          // Sort orders by timestamp in descending order (latest first)
          nonTodayOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (nonTodayOrders.isEmpty) {
            return const Center(child: Text('No past orders.'));
          }
          return ListView.builder(
            itemCount: nonTodayOrders.length,
            itemBuilder: (context, index) {
              final order = nonTodayOrders[index];
              return OrderTile(
                order: order,
                onStatusChanged: (newStatus) async {
                  await ref.read(sellerOrderServiceProvider).updateOrderStatus(
                        order.sellerId,
                        order.buyerId,
                        order.id,
                        newStatus,
                      );
                },
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
