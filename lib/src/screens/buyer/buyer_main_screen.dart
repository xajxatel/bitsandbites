import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'buyer_home_screen.dart';
import 'cart_screen.dart';
import 'past_orders_screen.dart';
import 'package:unicons/unicons.dart'; // Import Unicons
import 'package:bottom_bar_matu/bottom_bar_matu.dart'; // Import bottom_bar_matu

class BuyerMainScreen extends ConsumerStatefulWidget {
  const BuyerMainScreen({Key? key}) : super(key: key);

  @override
  _BuyerMainScreenState createState() => _BuyerMainScreenState();
}

class _BuyerMainScreenState extends ConsumerState<BuyerMainScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    BuyerHomeScreen(),
    CartScreen(),
    PastOrdersScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomBarDoubleBullet(
        selectedIndex: _selectedIndex,
        items: [
          BottomBarItem(iconData: UniconsLine.store, label: 'Outlets'),
          BottomBarItem(iconData: UniconsLine.shopping_cart, label: 'Cart'),
          BottomBarItem(iconData: UniconsLine.history, label: 'Orders'),
        ],
        onSelect: _onItemTapped,
        backgroundColor: Colors.white,
        color: Colors.blue.shade900,
      ),
    );
  }
}
