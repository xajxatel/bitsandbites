import 'package:bitsandbites/src/providers/menu_provider.dart';
import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:bitsandbites/src/widgets/rectactangular_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/menu_item_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/seller_provider.dart';
import 'menu_item_screen.dart';
import 'package:unicons/unicons.dart'; // Import Unicons
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

class MenuManagementScreen extends ConsumerStatefulWidget {
  const MenuManagementScreen({Key? key}) : super(key: key);

  @override
  _MenuManagementScreenState createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends ConsumerState<MenuManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(authStateChangesProvider).value?.uid;
    if (userId == null) {
      return const Scaffold(
        body: Center(child: LoadingIndicator()),
      );
    }

    final sellerStream = ref.watch(sellerDocProvider(userId));
    final menuItemsStream = ref.watch(sellerMenuItemsProvider(userId));

    return sellerStream.when(
      data: (seller) {
        final shopName = seller.shopName;

        return Scaffold(
          appBar: AppBar(
            title: !_isSearching
                ? Text(shopName)
                : TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
            actions: [
              if (!_isSearching)
                IconButton(
                  icon: const Icon(UniconsLine.search),
                  onPressed: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                ),
              if (_isSearching)
                IconButton(
                  icon: const Icon(UniconsLine.times),
                  onPressed: () {
                    setState(() {
                      _isSearching = false;
                      _searchQuery = '';
                      _searchController.clear();
                    });
                  },
                ),
              if (!_isSearching)
                IconButton(
                  icon: const Icon(UniconsLine.plus_square), // Plus Icon
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MenuItemScreen(
                        sellerId: userId,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          body: menuItemsStream.when(
            data: (menuItems) {
              if (menuItems.isEmpty) {
                return const Center(child: Text('No menu items yet.'));
              }

              // Filter the menu items based on the search query
              final filteredItems = menuItems.where((item) {
                return item.name
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase());
              }).toList();

              return ListView.builder(
                itemCount: filteredItems.length,
                itemBuilder: (context, index) {
                  final menuItem = filteredItems[index];
                  return ListTile(
                    title: Text(menuItem.name),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Price: ₹${menuItem.price}'),
                        Row(
                          children: [
                            const Icon(Icons.star,
                                color: Colors.yellow, size: 20),
                            Text(
                              '${menuItem.rating.toStringAsFixed(1)} (${menuItem.numberOfRatings})',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ],
                        ),
                      ],
                    ),
                    trailing: RectangularSwitch(
                      value: menuItem.isAvailable,
                      onChanged: (value) async {
                        final updatedItem =
                            menuItem.copyWith(isAvailable: value);
                        await ref
                            .read(sellerProvider)
                            .updateMenuItem(userId, updatedItem);
                      },
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MenuItemScreen(
                          sellerId: userId,
                          menuItem: menuItem,
                        ),
                      ),
                    ),
                    onLongPress: () async {
                      final deleteConfirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text(
                              'Delete Menu Item?',
                              style: TextStyle(
                                  color: Colors.blue.shade900,
                                  fontWeight: FontWeight.bold),
                            ),
                            content: const Text(
                              'Are you sure you want to delete this item? This action cannot be undone.',
                              style: TextStyle(fontSize: 16),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child:  Text('Cancel',
                                    style:
                                        TextStyle(color: Colors.blue.shade900)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          );
                        },
                      );

                      if (deleteConfirmed == true) {
                        await ref
                            .read(sellerProvider)
                            .deleteMenuItem(userId, menuItem.id);
                      }
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
          ),
        );
      },
      loading: () => const Center(child: LoadingIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}
