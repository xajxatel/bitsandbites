import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:neopop/neopop.dart'; // Import NeoPop
import 'package:unicons/unicons.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import '../models/order_model.dart';
import '../providers/seller_provider.dart';
import '../screens/buyer/rate_food_screen.dart';

class BuyerOrderTile extends ConsumerWidget {
  final OrderItem order;

  const BuyerOrderTile({Key? key, required this.order}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sellerStream = ref.watch(sellerDetailsProvider(order.sellerId));
    final totalItems =
        order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return sellerStream.when(
      data: (seller) {
        final sellerName = seller.shopName;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.grey, width: 2),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#Order ${order.orderNumber % 2000 == 0 ? 2000 : order.orderNumber % 2000}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                    color: Colors.blue.shade900,
                  ),
                ),
                const SizedBox(height: 8.0),
                Text(
                  '$sellerName',
                  style: const TextStyle(
                      fontSize: 17.0, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8.0),
                ...order.items
                    .map((item) => Text(
                          '${item.name} x${item.quantity}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16.0),
                        ))
                    .toList(),
                const SizedBox(height: 8.0),
                Text('Total Price: ₹${order.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16)),
                Text('Total Items: $totalItems',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8.0),
                Text(
                  'Time: ${DateFormat('HH:mm').format(order.timestamp.toDate())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  'Date: ${DateFormat('dd-MM-yyyy').format(order.timestamp.toDate())}',
                  style: const TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(
                      order.status == 'Ready'
                          ? UniconsLine.check_circle
                          : UniconsLine.hourglass,
                      color:
                          order.status == 'Ready' ? Colors.green : Colors.red,
                      size: 40.0, // Double the size of the icon
                    ),
                    NeoPopButton(
                      color: Colors.blue.shade900!,
                      onTapUp: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RateFoodScreen(order: order),
                          ),
                        );
                      },
                      onTapDown: () {},
                      child: const Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(UniconsLine.star, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              'Rate Food',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
