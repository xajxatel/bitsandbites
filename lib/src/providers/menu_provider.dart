import 'package:bitsandbites/src/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/menu_item_model.dart';

final sellerMenuItemsProvider =
    StreamProvider.family<List<MenuItem>, String>((ref, sellerId) {
  return FirebaseFirestore.instance
      .collection('sellers')
      .doc(sellerId)
      .collection('menuItems')
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
          .toList());
});

final averageRatingProvider = StreamProvider.family<double, String>((ref, sellerId) {
  final menuItemsService = ref.read(menuItemsProvider);
  return menuItemsService.fetchAverageRating(sellerId);
});

final menuItemsProvider = Provider<MenuItemsService>((ref) {
  return MenuItemsService();
});

class MenuItemsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<MenuItem>> getMenuItems(String sellerId) {
    return _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('menuItems')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MenuItem.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<MenuItem> getMenuItem(String sellerId, String itemId) async {
    final snapshot = await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('menuItems')
        .doc(itemId)
        .get();
    return MenuItem.fromMap(snapshot.data()!, snapshot.id);
  }

  Future<void> updateMenuItem(String sellerId, MenuItem menuItem) async {
    await _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('menuItems')
        .doc(menuItem.id)
        .update(menuItem.toMap());
  }

  Future<Map<String, double>> fetchExistingRatings(
      String buyerId, List<CartItem> items) async {
    final Map<String, double> ratings = {};
    for (var item in items) {
      final ratingSnapshot = await _firestore
          .collection('ratings')
          .doc(buyerId)
          .collection('ratedItems')
          .doc(item.id)
          .get();
      if (ratingSnapshot.exists) {
        ratings[item.id] = ratingSnapshot.data()?['rating']?.toDouble() ?? 0.0;
      }
    }
    return ratings;
  }

  Future<void> rateMenuItem(String buyerId, String sellerId, String orderId,
      String itemId, double rating) async {
    final itemRef = _firestore
        .collection('sellers')
        .doc(sellerId)
        .collection('menuItems')
        .doc(itemId);
    final itemSnapshot = await itemRef.get();
    if (itemSnapshot.exists) {
      final currentRating = itemSnapshot.data()?['rating']?.toDouble() ?? 0.0;
      final currentNumberOfRatings =
          itemSnapshot.data()?['numberOfRatings']?.toInt() ?? 0;

      // Create a unique rating ID for each order
      final ratingId = '$orderId-$itemId';

      // Check if the user has already rated this item in this order
      final existingRatingSnapshot = await _firestore
          .collection('ratings')
          .doc(buyerId)
          .collection('ratedItems')
          .doc(ratingId)
          .get();

      if (existingRatingSnapshot.exists) {
        // If the user has already rated this item in this order, update the rating without changing the number of ratings
        final existingRating =
            existingRatingSnapshot.data()?['rating']?.toDouble() ?? 0.0;
        final newRating = ((currentRating * currentNumberOfRatings) -
                existingRating +
                rating) /
            currentNumberOfRatings;

        await itemRef.update({
          'rating': newRating,
        });

        await _firestore
            .collection('ratings')
            .doc(buyerId)
            .collection('ratedItems')
            .doc(ratingId)
            .update({
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        // If the user has not rated this item in this order before, add the new rating and increment the number of ratings
        final newNumberOfRatings = currentNumberOfRatings + 1;
        final newRating = ((currentRating * currentNumberOfRatings) + rating) /
            newNumberOfRatings;

        await itemRef.update({
          'rating': newRating,
          'numberOfRatings': newNumberOfRatings,
        });

        await _firestore
            .collection('ratings')
            .doc(buyerId)
            .collection('ratedItems')
            .doc(ratingId)
            .set({
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }

  Future<void> updateMenuItemRating(String buyerId, String sellerId,
      String orderId, String itemId, double rating) async {
    await rateMenuItem(buyerId, sellerId, orderId, itemId, rating);
  }
  Stream<double> fetchAverageRating(String sellerId) {
  return _firestore
      .collection('sellers')
      .doc(sellerId)
      .collection('menuItems')
      .snapshots()
      .map((snapshot) {
    double totalRatingProduct = 0.0;
    num totalRatingsCount = 0;

    for (var item in snapshot.docs) {
      final rating = (item.data()['rating'] ?? 0.0).toDouble();
      final numberOfRatings = (item.data()['numberOfRatings'] ?? 0).toInt();

      if (rating > 0 && numberOfRatings > 0) {
        totalRatingProduct += rating * numberOfRatings;
        totalRatingsCount += numberOfRatings;
      }
    }

    return totalRatingsCount > 0 ? totalRatingProduct / totalRatingsCount : 0.0;
  });
}


}


