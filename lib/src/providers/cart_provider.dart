import 'package:bitsandbites/src/models/cart_item_model.dart';
import 'package:bitsandbites/src/models/menu_item_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(MenuItem menuItem) {
    if (state.isEmpty || state.first.sellerId == menuItem.sellerId) {
      final existingItem = state.firstWhere(
        (item) => item.id == menuItem.id,
        orElse: () => CartItem(
          id: menuItem.id,
          name: menuItem.name,
          price: menuItem.price,
          quantity: 0,
          sellerId: menuItem.sellerId,
          isVeg: menuItem.isVeg,
        ),
      );

      if (existingItem.quantity > 0) {
        updateQuantity(menuItem.id, existingItem.quantity + 1);
      } else {
        state = [
          ...state,
          CartItem(
            id: menuItem.id,
            name: menuItem.name,
            price: menuItem.price,
            quantity: 1,
            sellerId: menuItem.sellerId,
            isVeg: menuItem.isVeg,
          )
        ];
      }
    } else {
      throw Exception("Clear cart before ordering from a different outlet");
    }
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity == 0) {
      removeItem(itemId);
    } else {
      state = [
        for (final item in state)
          if (item.id == itemId) item.copyWith(quantity: quantity) else item,
      ];
    }
  }

  void removeItem(String itemId) {
    state = state.where((item) => item.id != itemId).toList();
  }

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
