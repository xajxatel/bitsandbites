import 'package:bitsandbites/src/models/order_model.dart';
import 'package:bitsandbites/src/models/seller_model.dart';
import 'package:bitsandbites/src/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';



final buyerProvider = Provider<BuyerService>((ref) {
  return BuyerService();
});

class BuyerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getBuyerDetails(String buyerId) async {
    final doc = await _firestore.collection('buyers').doc(buyerId).get();
    return doc.data();
  }
}


final menuItemsProvider = StreamProvider.family<List<MenuItem>, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .collection('menuItems')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => MenuItem.fromMap(doc.data(), doc.id)).toList());
});
final buyerOrdersProvider = StreamProvider<List<OrderItem>>((ref) {
  final userId = ref.watch(authStateChangesProvider).value?.uid;
  if (userId == null) {
    return const Stream.empty();
  }
  return FirebaseFirestore.instance
      .collection('buyers')
      .doc(userId)
      .collection('orders')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => OrderItem.fromMap(doc.data(), doc.id)).toList());
});



final sellersProvider = StreamProvider<List<Seller>>((ref) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .snapshots()
      .map((snapshot) => snapshot.docs.map((doc) => Seller.fromMap(doc.data(), doc.id)).toList());
});
