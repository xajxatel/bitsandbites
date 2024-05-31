import 'package:bitsandbites/src/models/order_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:neopop/neopop.dart'; // Import NeoPop
import 'package:unicons/unicons.dart'; // Import Unicons

class OrderTile extends StatelessWidget {
  final OrderItem order;
  final void Function(String) onStatusChanged;

  const OrderTile({
    Key? key,
    required this.order,
    required this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalItems =
        order.items.fold<int>(0, (sum, item) => sum + item.quantity);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey, width: 1),
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
            Text('${order.buyerName}\'s Order',
                style: const TextStyle(fontSize: 16)),
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
                style: const TextStyle(fontSize: 16)),
            Text(
                'Date: ${DateFormat('dd-MM-yyyy').format(order.timestamp.toDate())}',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  order.status == 'Ready'
                      ? UniconsLine.check_circle
                      : UniconsLine.hourglass,
                  color: order.status == 'Ready' ? Colors.green : Colors.red,
                  size: 40.0, // Double the size of the icon
                ),
                NeoPopButton(
                  color: Colors.blue.shade900!,
                  onTapUp: () {
                    final newStatus =
                        order.status == 'Ready' ? 'Preparing' : 'Ready';
                    onStatusChanged(newStatus);
                  },
                  onTapDown: () {},
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Text(
                      order.status == 'Ready' ? 'Preparing' : 'Ready',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
