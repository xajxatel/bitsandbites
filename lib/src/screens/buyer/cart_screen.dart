import 'package:bitsandbites/src/screens/buyer/order_success_screen.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

import '../../providers/auth_provider.dart';
import '../../providers/buyer_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/seller_provider.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  _CartScreenState createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cartItems = ref.watch(cartProvider);
    final auth = ref.watch(authStateChangesProvider).value;

    double getTotalAmount() {
      return cartItems.fold(
          0.0, (sum, item) => sum + item.price * item.quantity);
    }

    Future<void> _placeOrder() async {
      setState(() {
        _isLoading = true;
      });

      final orderService = ref.read(orderProvider);
      final buyerService = ref.read(buyerProvider);
      final buyerId = auth?.uid;

      if (buyerId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to place an order.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Fetch the buyer's name using the provider
      final buyerDetails = await buyerService.getBuyerDetails(buyerId);
      final buyerName = buyerDetails?['name'] ?? 'Buyer';

      final itemsToOrder =
          cartItems.where((item) => item.quantity > 0).toList();
      if (itemsToOrder.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Your cart is empty.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final sellerId = itemsToOrder.first.sellerId;
      final sellerStatusStream = ref.watch(sellerStatusProvider(sellerId));

      sellerStatusStream.when(
        data: (isOpen) async {
          if (!isOpen) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('The store is currently closed.')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          // Check availability of each item
          bool allItemsAvailable = true;
          for (var item in itemsToOrder) {
            final itemDoc =
                await ref.read(sellerProvider).getMenuItem(sellerId, item.id);
            if (itemDoc != null && !itemDoc.isAvailable) {
              allItemsAvailable = false;
              break;
            }
          }

          if (!allItemsAvailable) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text(
                      'One or more items in your cart are not available.')),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }

          final totalAmount = getTotalAmount();
          await orderService.addOrder(
              buyerId, buyerName, sellerId, itemsToOrder, totalAmount);

          // Clear the cart after placing the order
          ref.read(cartProvider.notifier).clearCart();

          setState(() {
            _isLoading = false;
          });

          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const OrderSuccessScreen()),
            (Route<dynamic> route) => false,
          );
        },
        loading: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Checking store status...')),
        ),
        error: (error, stack) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
          setState(() {
            _isLoading = false;
          });
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Cart'),
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : cartItems.isEmpty
              ? const Center(child: Text('Your cart is empty.'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return item.quantity > 0
                              ? Card(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 8.0, horizontal: 16.0),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              backgroundColor: item.isVeg
                                                  ? Colors.green
                                                  : Colors.red,
                                              radius: 5,
                                            ),
                                            const SizedBox(width: 8.0),
                                            Expanded(
                                              child: Text(
                                                item.name,
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                ref
                                                    .read(cartProvider.notifier)
                                                    .updateQuantity(item.id,
                                                        item.quantity - 1);
                                              },
                                            ),
                                            Text(item.quantity.toString(),
                                                style: const TextStyle(
                                                    fontSize: 16)),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                ref
                                                    .read(cartProvider.notifier)
                                                    .updateQuantity(item.id,
                                                        item.quantity + 1);
                                              },
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8.0),
                                        Text(
                                          'Price per item: ₹${item.price.toStringAsFixed(2)}',
                                          style: const TextStyle(fontSize: 16),
                                        ),
                                        Text(
                                          'Total price: ₹${(item.price * item.quantity).toStringAsFixed(2)}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : Container();
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(
                            'Total Price: ₹${getTotalAmount().toStringAsFixed(2)}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.end,
                          ),
                          const SizedBox(height: 16.0),
                          SizedBox(
                            width: 170,
                            child: NeoPopButton(
                              color: Colors.blue.shade900!,
                              onTapUp: _placeOrder,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: Center(
                                  child: Text(
                                    'Place Order',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
