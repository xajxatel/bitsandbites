import 'package:bitsandbites/src/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_model.dart';

final orderProvider = Provider<OrderService>((ref) {
  return OrderService();
});
final buyerOrdersProvider =
    StreamProvider.family<List<OrderItem>, String>((ref, buyerId) {
  return FirebaseFirestore.instance
      .collection('buyers')
      .doc(buyerId)
      .collection('orders')
      .orderBy('timestamp',
          descending: true) // Order by timestamp in descending order
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => OrderItem.fromMap(doc.data(), doc.id))
          .toList());
});

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createOrder(OrderItem order) async {
    await _firestore.collection('orders').add(order.toMap());
  }

  Stream<List<OrderItem>> getOrders(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<void> updateOrderStatus(
      String sellerId, String orderId, String status) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .doc(orderId)
        .update({'status': status});
  }

  Future<void> placeOrder(
      String buyerId, String sellerId, OrderItem order) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .doc(order.id)
        .set(order.toMap());
    await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('orders')
        .doc(order.id)
        .set(order.toMap());
  }

  Future<String> addOrder(String buyerId, String buyerName, String sellerId,
      List<CartItem> items, double totalAmount) async {
    final orderId = _firestore.collection('orders').doc().id;
    final orderNumber = await _getOrderNumberForSeller(sellerId);

    final order = OrderItem(
      id: orderId,
      buyerId: buyerId,
      buyerName: buyerName,
      sellerId: sellerId,
      items: items,
      status: 'Pending',
      totalAmount: totalAmount,
      timestamp: Timestamp.now(),
      orderNumber: orderNumber,
    );

    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .doc(orderId)
        .set(order.toMap());
    await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('orders')
        .doc(orderId)
        .set(order.toMap());

    return orderId;
  }

  Future<Map<String, double>> calculateBuyerExpenses(String buyerId) async {
    double today = 0.0;
    double thisMonth = 0.0;
    double lifetime = 0.0;

    final ordersSnapshot = await _firestore
        .collection('buyers')
        .doc(buyerId)
        .collection('orders')
        .get();

    final now = DateTime.now();

    for (var doc in ordersSnapshot.docs) {
      final order = OrderItem.fromMap(doc.data(), doc.id);
      for (var item in order.items) {
        final itemTotal = item.price * item.quantity;
        lifetime += itemTotal;
        if (order.timestamp.toDate().day == now.day &&
            order.timestamp.toDate().month == now.month &&
            order.timestamp.toDate().year == now.year) {
          today += itemTotal;
        }
        if (order.timestamp.toDate().month == now.month &&
            order.timestamp.toDate().year == now.year) {
          thisMonth += itemTotal;
        }
      }
    }

    return {
      'today': today,
      'thisMonth': thisMonth,
      'lifetime': lifetime,
    };
  }

  Future<int> _getOrderNumberForSeller(String sellerId) async {
    final sellerOrders = await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .get();
    return sellerOrders.size + 1;
  }

  Future<int> getOrderNumber(String sellerId, String orderId) async {
    final sellerOrders = await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('orders')
        .get();
    return sellerOrders.size + 1;
  }

  Future<void> updateOrderNumber(String orderId, int orderNumber) async {
    await _firestore
        .collection('orders')
        .doc(orderId)
        .update({'orderNumber': orderNumber});
  }

  Future<void> updateMenuItemRating(String sellerId, String itemId,
      double rating, int numberOfRatings) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('menuItems')
        .doc(itemId)
        .update({
      'rating': rating,
      'numberOfRatings': numberOfRatings,
    });
  }
}
