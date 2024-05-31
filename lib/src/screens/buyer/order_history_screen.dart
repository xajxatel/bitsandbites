import 'package:bitsandbites/src/widgets/loading_indicator.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/order_model.dart';


class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authStateChangesProvider).value;
    final ordersStream = ref.watch(buyerOrdersProvider(user?.uid ?? ''));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order History'),
      ),
      body: ordersStream.when(
        data: (orders) {
          if (orders.isEmpty) {
            return const Center(child: Text('No orders yet.'));
          }
          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Order ID: ${order.id}'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Total: \$${order.totalAmount.toStringAsFixed(2)}'),
                    Text('Status: ${order.status}'),
                    ...order.items.map((item) => Text(
                        '${item.name} - ${item.price} x ${item.quantity}')),
                  ],
                ),
                trailing: Text(order.status),
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
