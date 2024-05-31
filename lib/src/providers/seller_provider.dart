import 'package:bitsandbites/src/models/order_model.dart';
import 'package:bitsandbites/src/models/seller_model.dart';
import 'package:bitsandbites/src/providers/auth_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';


final menuItemsProvider = StreamProvider<List<MenuItem>>((ref) {
  final userId = ref.watch(authStateChangesProvider).value?.uid;
  if (userId == null) {
    return const Stream.empty();
  }
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(userId)
      .collection('menuItems')
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => MenuItem.fromMap(doc.data(), doc.id)).toList());
});

final allSellersProvider = StreamProvider<List<Seller>>((ref) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .snapshots()
      .map((snapshot) {
        List<Seller> sellers = snapshot.docs
            .map((doc) => Seller.fromMap(doc.data()!, doc.id))
            .toList();

        // Sort sellers so that open outlets appear at the top
        sellers.sort((a, b) => (b.isOpen ? 1 : 0).compareTo(a.isOpen ? 1 : 0));

        return sellers;
      });
});

final sellerStatusProvider = StreamProvider.family<bool, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .snapshots()
      .map((snapshot) => snapshot.data()?['isOpen'] ?? false);
});

final openSellersProvider = StreamProvider<List<Seller>>((ref) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .where('isOpen', isEqualTo: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Seller.fromMap(doc.data()!, doc.id))
          .toList());
});

final sellerProvider = Provider<SellerService>((ref) {
  return SellerService();
});

final sellerDocProvider = StreamProvider.family<Seller, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .snapshots()
      .map((snapshot) => Seller.fromMap(snapshot.data()!, snapshot.id));
});



final typesProvider = StreamProvider.family<List<String>, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .collection('menuItems')
      .snapshots()
      .map((snapshot) {
        final typesSet = <String>{};
        for (var doc in snapshot.docs) {
          final data = doc.data();
          if (data['type'] != null) {
            typesSet.add(data['type'] as String);
          }
        }
        return typesSet.toList();
      });
});

class SellerService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addSeller(String userId, Map<String, dynamic> sellerData) async {
    await _firestore.collection('sellers').doc(userId).set(sellerData);
  }

  Future<void> updateSellerStatus(String userId, bool isOpen) async {
    await _firestore.collection('sellers').doc(userId).update({'isOpen': isOpen});
  }

  Future<void> addMenuItem(String userId, MenuItem menuItem) async {
    await _firestore
        .collection('sellers')
        .doc(userId)
        .collection('menuItems')
        .add(menuItem.toMap());
  }
Future<MenuItem?> getMenuItem(String sellerId, String itemId) async {
    final itemDoc = await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('menuItems')
        .doc(itemId)
        .get();
    if (itemDoc.exists) {
      return MenuItem.fromMap(itemDoc.data()!, itemDoc.id);
    }
    return null;
  }
  Future<void> updateMenuItem(String userId, MenuItem menuItem) async {
    await _firestore
        .collection('sellers')
        .doc(userId)
        .collection('menuItems')
        .doc(menuItem.id)
        .update(menuItem.toMap());
  }

  Future<void> deleteMenuItem(String userId, String itemId) async {
    await _firestore
        .collection('sellers')
        .doc(userId)
        .collection('menuItems')
        .doc(itemId)
        .delete();
  }

  Stream<Seller> getSeller(String sellerId) {
    return _firestore.collection('sellers').doc(sellerId).snapshots().map(
        (snapshot) => Seller.fromMap(snapshot.data()!, snapshot.id));
  }
  Future<Seller?> getSellerDetails(String sellerId) async {
    try {
      final docSnapshot = await _firestore.collection('sellers').doc(sellerId).get();
      if (docSnapshot.exists) {
        return Seller.fromMap(docSnapshot.data()!, docSnapshot.id);
      }
    } catch (e) {
      print('Error getting seller details: $e');
    }
    return null;
  }

  Future<void> updateSeller(String userId, Seller updatedSeller) async {
    await _firestore.collection('sellers').doc(userId).update(updatedSeller.toMap());
  }

  Future<void> addType(String userId, String type) async {
    await _firestore
        .collection('sellers')
        .doc(userId)
        .collection('types')
        .doc(type)
        .set({});
  }

  Future<void> deleteType(String userId, String type) async {
    await _firestore
        .collection('sellers')
        .doc(userId)
        .collection('types')
        .doc(type)
        .delete();
  }

  Future<void> updateMenuItemRating(
      String userId, String itemId, double newRating, int newNumberOfRatings) async {
    await _firestore.collection('sellers').doc(userId).collection('menuItems').doc(itemId).update({
      'rating': newRating,
      'numberOfRatings': newNumberOfRatings,
    });
  }
Future<Map<String, double>> calculateSellerEarnings(String sellerId) async {
    double today = 0.0;
    double thisMonth = 0.0;
    double lifetime = 0.0;

    final ordersSnapshot = await _firestore
        .collection('sellers')
        .doc(sellerId)
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
}




final sellerOrdersProvider = StreamProvider.family<List<OrderItem>, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .collection('orders')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => OrderItem.fromMap(doc.data(), doc.id)).toList());
});


final sellerOrderServiceProvider = Provider<SellerOrderService>((ref) {
  return SellerOrderService();
});
final sellerDetailsProvider = StreamProvider.family<Seller, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .snapshots()
      .map((snapshot) => Seller.fromMap(snapshot.data()!, snapshot.id));
});
class SellerOrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> updateOrderStatus(String sellerId, String buyerId, String orderId, String status) async {
    final batch = _firestore.batch();

    final sellerOrderRef = _firestore.collection('sellers').doc(sellerId).collection('orders').doc(orderId);
    final buyerOrderRef = _firestore.collection('buyers').doc(buyerId).collection('orders').doc(orderId);

    batch.update(sellerOrderRef, {'status': status});
    batch.update(buyerOrderRef, {'status': status});

    await batch.commit();
  }
}
