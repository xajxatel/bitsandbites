import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart'; // Import the Rating Bar package
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import '../../models/order_model.dart';
import '../../providers/menu_provider.dart';

class RateFoodScreen extends ConsumerStatefulWidget {
  final OrderItem order;

  const RateFoodScreen({Key? key, required this.order}) : super(key: key);

  @override
  _RateFoodScreenState createState() => _RateFoodScreenState();
}

class _RateFoodScreenState extends ConsumerState<RateFoodScreen> {
  final Map<String, double> _ratings = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeRatings();
  }

  Future<void> _initializeRatings() async {
    final menuItemsService = ref.read(menuItemsProvider);
    final existingRatings = await menuItemsService.fetchExistingRatings(
        widget.order.buyerId, widget.order.items);
    setState(() {
      _ratings.addAll(existingRatings);
      // Initialize any unrated items to 0
      for (var item in widget.order.items) {
        _ratings.putIfAbsent(item.id, () => 0.0);
      }
    });
  }

  Future<void> _submitRatings() async {
    setState(() {
      _isLoading = true;
    });
    final menuItemsService = ref.read(menuItemsProvider);
    for (var item in widget.order.items) {
      final rating = _ratings[item.id] ?? 0.0;
      if (rating > 0) {
        await menuItemsService.updateMenuItemRating(widget.order.buyerId,
            widget.order.sellerId, widget.order.id, item.id, rating);
      }
    }
    setState(() {
      _isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your rating!')),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rate Food'),
      ),
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: widget.order.items.length,
            itemBuilder: (context, index) {
              final item = widget.order.items[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.name,
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8.0),
                      RatingBar.builder(
                        initialRating: _ratings[item.id] ?? 0.0,
                        minRating: 1,
                        direction: Axis.horizontal,
                        allowHalfRating: true,
                        itemCount: 5,
                        itemPadding:
                            const EdgeInsets.symmetric(horizontal: 4.0),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _ratings[item.id] = rating;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          if (_isLoading) const LoadingIndicator()
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _submitRatings,
        child: const Icon(
          Icons.check,
          color: Colors.white,
        ),
        backgroundColor: Colors.blue.shade900,
      ),
    );
  }
}
