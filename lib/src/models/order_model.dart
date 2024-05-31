import 'package:cloud_firestore/cloud_firestore.dart';

import 'cart_item_model.dart';

class OrderItem {
  final String id;
  final String buyerId;
  final String buyerName;
  final String sellerId;
  final List<CartItem> items;
  final String status;
  final double totalAmount;
  final Timestamp timestamp;
  final int orderNumber;

  OrderItem({
    required this.id,
    required this.buyerId,
    required this.buyerName,
    required this.sellerId,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.timestamp,
    required this.orderNumber,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data, String documentId) {
    return OrderItem(
      id: documentId,
      buyerId: data['buyerId'] ?? '',
      buyerName: data['buyerName'] ?? 'Buyer',
      sellerId: data['sellerId'] ?? '',
      items: (data['items'] as List<dynamic>)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      status: data['status'] ?? 'Pending',
      totalAmount: data['totalAmount']?.toDouble() ?? 0.0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
      orderNumber: data['orderNumber'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'buyerId': buyerId,
      'buyerName': buyerName,
      'sellerId': sellerId,
      'items': items.map((item) => item.toMap()).toList(),
      'status': status,
      'totalAmount': totalAmount,
      'timestamp': timestamp,
      'orderNumber': orderNumber,
    };
  }
}
