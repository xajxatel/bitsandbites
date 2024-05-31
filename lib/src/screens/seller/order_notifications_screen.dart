import 'package:bitsandbites/src/providers/seller_provider.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:bitsandbites/src/widgets/order_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';


class OrderNotificationsScreen extends ConsumerWidget {
  const OrderNotificationsScreen({Key? key}) : super(key: key);

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
        title: const Text('''Today's Orders'''),
      ),
      body: ordersStream.when(
        data: (orders) {
          // Filter orders for today
          final today = DateTime.now();
          final todayOrders = orders.where((order) {
            final orderDate = order.timestamp.toDate();
            return orderDate.year == today.year &&
                orderDate.month == today.month &&
                orderDate.day == today.day;
          }).toList();

          // Sort orders by timestamp in descending order (latest first)
          todayOrders.sort((a, b) => b.timestamp.compareTo(a.timestamp));

          if (todayOrders.isEmpty) {
            return const Center(child: Text('No orders for today.'));
          }
          return ListView.builder(
            itemCount: todayOrders.length,
            itemBuilder: (context, index) {
              final order = todayOrders[index];
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
