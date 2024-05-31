import 'package:bitsandbites/src/widgets/loading_screen.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unicons/unicons.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import '../../models/cart_item_model.dart';
import '../../models/menu_item_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/menu_provider.dart';
import '../../providers/seller_provider.dart';

class OutletMenuScreen extends ConsumerStatefulWidget {
  final String sellerId;
  final String sellerName;

  const OutletMenuScreen({
    Key? key,
    required this.sellerId,
    required this.sellerName,
  }) : super(key: key);

  @override
  _OutletMenuScreenState createState() => _OutletMenuScreenState();
}

class _OutletMenuScreenState extends ConsumerState<OutletMenuScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  bool _isSearching = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 0, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuItemsStream = ref.watch(sellerMenuItemsProvider(widget.sellerId));
    final cartItems = ref.watch(cartProvider);
    final sellerStatusStream = ref.watch(sellerStatusProvider(widget.sellerId));
    final typesStream = ref.watch(typesProvider(widget.sellerId));

    return sellerStatusStream.when(
      data: (isOpen) {
        if (!isOpen) {
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Store Closed'),
                content: const Text(
                    'The store has been closed. You will be redirected to the home screen.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context)
                          .pop(); // Navigate back to home screen
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          });
        }

        return Scaffold(
          appBar: AppBar(
            title: !_isSearching
                ? Text(widget.sellerName)
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
            automaticallyImplyLeading: !_isSearching,
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
            ],
          ),
          body: typesStream.when(
            data: (types) {
              if (_tabController.length != types.length) {
                _tabController = TabController(
                  length: types.length,
                  vsync: this,
                  initialIndex: _currentIndex,
                )..addListener(() {
                    setState(() {
                      _currentIndex = _tabController.index;
                    });
                  });
              }

              if (types.isEmpty) {
                return const Center(child: Text('No menu items available.'));
              }
              return menuItemsStream.when(
                data: (menuItems) {
                  if (menuItems.isEmpty) {
                    return const Center(
                        child: Text('No menu items available.'));
                  }

                  // Combine all items across all categories when searching
                  final combinedItems = _searchQuery.isNotEmpty
                      ? menuItems.where((item) {
                          return item.name
                              .toLowerCase()
                              .contains(_searchQuery.toLowerCase());
                        }).toList()
                      : menuItems;

                  if (_isSearching) {
                    return combinedItems.isEmpty
                        ? const Center(
                            child: Text('No items match your search.'))
                        : ListView.builder(
                            itemCount: combinedItems.length,
                            itemBuilder: (context, index) {
                              final menuItem = combinedItems[index];
                              final cartItem = cartItems.firstWhere(
                                (item) => item.id == menuItem.id,
                                orElse: () => CartItem(
                                  isVeg: menuItem.isVeg,
                                  id: menuItem.id,
                                  name: menuItem.name,
                                  price: menuItem.price,
                                  quantity: 0,
                                  sellerId: menuItem.sellerId,
                                ),
                              );

                              return Card(
                                margin: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: menuItem.isVeg
                                        ? Colors.green
                                        : Colors.red,
                                    radius: 5,
                                  ),
                                  title: Text(menuItem.name,
                                      style: TextStyle(fontSize: 16)),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Price: ₹${menuItem.price.toStringAsFixed(2)}',
                                          style: TextStyle(fontSize: 15)),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              color: Colors.yellow, size: 23),
                                          Text(
                                            '${menuItem.rating.toStringAsFixed(1)} (${menuItem.numberOfRatings})',
                                            style:
                                                const TextStyle(fontSize: 15),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: menuItem.isAvailable
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove),
                                              onPressed: () {
                                                if (cartItem.quantity > 0) {
                                                  ref
                                                      .read(
                                                          cartProvider.notifier)
                                                      .updateQuantity(
                                                          cartItem.id,
                                                          cartItem.quantity -
                                                              1);
                                                }
                                              },
                                            ),
                                            Text(
                                              cartItem.quantity.toString(),
                                              style: TextStyle(fontSize: 14),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add),
                                              onPressed: () {
                                                try {
                                                  ref
                                                      .read(
                                                          cartProvider.notifier)
                                                      .addItem(menuItem);
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'You can only order from one store at once.'),
                                                    ),
                                                  );
                                                }
                                              },
                                            ),
                                          ],
                                        )
                                      : const Text('Not available',
                                          style: TextStyle(
                                              color: Colors.red, fontSize: 14)),
                                ),
                              );
                            },
                          );
                  }

                  Map<String, List<MenuItem>> categorizedItems = {};
                  for (var type in types) {
                    categorizedItems[type] =
                        menuItems.where((item) => item.type == type).toList();
                  }

                  return Column(
                    children: [
                      PreferredSize(
                        preferredSize: const Size.fromHeight(48.0),
                        child: types.isEmpty
                            ? const SizedBox.shrink()
                            : SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: ButtonsTabBar(
                                  controller: _tabController,
                                  borderColor: Colors.blue.shade900,
                                  unselectedBorderColor: Colors.grey,
                                  backgroundColor: Colors.blue.shade900!,
                                  unselectedBackgroundColor: Colors.grey[300],
                                  unselectedLabelStyle: GoogleFonts.inconsolata(
                                      color: Colors.blue.shade900,
                                      fontSize: 15),
                                  labelStyle: GoogleFonts.inconsolata(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                  tabs: types
                                      .map((type) => Tab(text: type))
                                      .toList(),
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  radius: 10,
                                  height: 50,
                                  borderWidth: 2,
                                ),
                              ),
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: types.map((type) {
                            final items = categorizedItems[type]!;
                            return items.isEmpty
                                ? const Center(
                                    child: Text('No items in this category.'))
                                : ListView.builder(
                                    itemCount: items.length,
                                    itemBuilder: (context, index) {
                                      final menuItem = items[index];
                                      final cartItem = cartItems.firstWhere(
                                        (item) => item.id == menuItem.id,
                                        orElse: () => CartItem(
                                          isVeg: menuItem.isVeg,
                                          id: menuItem.id,
                                          name: menuItem.name,
                                          price: menuItem.price,
                                          quantity: 0,
                                          sellerId: menuItem.sellerId,
                                        ),
                                      );

                                      return Card(
                                        margin: const EdgeInsets.all(8.0),
                                        child: ListTile(
                                          leading: CircleAvatar(
                                            backgroundColor: menuItem.isVeg
                                                ? Colors.green
                                                : Colors.red,
                                            radius: 5,
                                          ),
                                          title: Text(menuItem.name,
                                              style: TextStyle(fontSize: 16)),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                  'Price: ₹${menuItem.price.toStringAsFixed(2)}',
                                                  style:
                                                      TextStyle(fontSize: 15)),
                                              Row(
                                                children: [
                                                  const Icon(Icons.star,
                                                      color: Colors.yellow,
                                                      size: 23),
                                                  Text(
                                                    '${menuItem.rating.toStringAsFixed(1)} (${menuItem.numberOfRatings})',
                                                    style: const TextStyle(
                                                        fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          trailing: menuItem.isAvailable
                                              ? Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(
                                                          Icons.remove),
                                                      onPressed: () {
                                                        if (cartItem.quantity >
                                                            0) {
                                                          ref
                                                              .read(cartProvider
                                                                  .notifier)
                                                              .updateQuantity(
                                                                  cartItem.id,
                                                                  cartItem.quantity -
                                                                      1);
                                                        }
                                                      },
                                                    ),
                                                    Text(
                                                      cartItem.quantity
                                                          .toString(),
                                                      style: TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    IconButton(
                                                      icon:
                                                          const Icon(Icons.add),
                                                      onPressed: () {
                                                        try {
                                                          ref
                                                              .read(cartProvider
                                                                  .notifier)
                                                              .addItem(
                                                                  menuItem);
                                                        } catch (e) {
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                            const SnackBar(
                                                              content: Text(
                                                                  'You can only order from one store at once.'),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ],
                                                )
                                              : const Text('Not available',
                                                  style: TextStyle(
                                                      color: Colors.red,
                                                      fontSize: 14)),
                                        ),
                                      );
                                    },
                                  );
                          }).toList(),
                        ),
                      ),
                    ],
                  );
                },
                loading: () => const Center(child: LoadingIndicator()),
                error: (error, stack) => Center(child: Text('Error: $error')),
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (error, stack) => Center(child: Text('Error loading types')),
          ),
        );
      },
      loading: () => const Scaffold(
        body: Center(child: LoadingIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
