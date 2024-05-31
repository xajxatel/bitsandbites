import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:unicons/unicons.dart'; // Import Unicons
import 'package:bottom_bar_matu/bottom_bar_matu.dart'; // Import bottom_bar_matu
import 'menu_management_screen.dart';
import 'order_notifications_screen.dart';
import 'seller_order_history_screen.dart';
import 'seller_settings_screen.dart';

class SellerHomeScreen extends ConsumerStatefulWidget {
  const SellerHomeScreen({Key? key}) : super(key: key);

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends ConsumerState<SellerHomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    MenuManagementScreen(),
    OrderNotificationsScreen(),
    SellerOrderHistoryScreen(),
    SellerSettingsScreen(),
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
          BottomBarItem(iconData: UniconsLine.restaurant, label: 'Menu'),
          BottomBarItem(iconData: UniconsLine.bell, label: 'Orders'),
          BottomBarItem(iconData: UniconsLine.history, label: 'History'),
          BottomBarItem(iconData: UniconsLine.setting, label: 'Settings'),
        ],
        onSelect: _onItemTapped,
        backgroundColor: Colors.white,
        color: Colors.blue.shade900,
      ),
    );
  }
}
