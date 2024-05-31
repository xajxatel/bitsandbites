import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import '../providers/menu_provider.dart';
import '../widgets/loading_screen.dart';

class OutletTile extends ConsumerWidget {
  final String shopName;
  final bool isOpen;
  final String cuisines;
  final String phone;
  final String sellerId;
  final String avatar;

  const OutletTile({
    Key? key,
    required this.shopName,
    required this.isOpen,
    required this.cuisines,
    required this.phone,
    required this.sellerId,
    required this.avatar,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final averageRatingAsyncValue = ref.watch(averageRatingProvider(sellerId));

    return averageRatingAsyncValue.when(
      data: (averageRating) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade300, width: 2),
          ),
          margin: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8.0),
                      bottomLeft: Radius.circular(8.0),
                    ),
                    child: Image.asset(
                      avatar,
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 4.0,
                      ),
                      decoration: BoxDecoration(
                        color: isOpen ? Colors.green : Colors.red,
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      child: Text(
                        isOpen ? 'Open' : 'Closed',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shopName,
                              style: TextStyle(
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 20),
                          const SizedBox(width: 4.0),
                          Text(
                            averageRating > 0
                                ? averageRating.toStringAsFixed(1)
                                : '-',
                            style: const TextStyle(fontSize: 16.0),
                          ),
                          const SizedBox(width: 16.0),
                        ],
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        cuisines,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: phone));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text('Phone number copied to clipboard'),
                                ),
                              );
                            },
                            child: Icon(
                              UniconsLine.phone,
                            ),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            phone,
                            style: TextStyle(
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
