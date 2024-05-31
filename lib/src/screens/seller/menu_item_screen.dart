import 'package:bitsandbites/src/widgets/rectactangular_switch.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:neopop/widgets/buttons/neopop_button/neopop_button.dart';

import '../../models/menu_item_model.dart';
import '../../providers/seller_provider.dart';
import '../../widgets/rectangular_radio_button.dart'; // Import RectangularRadioButton

class MenuItemScreen extends ConsumerStatefulWidget {
  final String sellerId;
  final MenuItem? menuItem;

  const MenuItemScreen({
    Key? key,
    required this.sellerId,
    this.menuItem,
  }) : super(key: key);

  @override
  _MenuItemScreenState createState() => _MenuItemScreenState();
}

class _MenuItemScreenState extends ConsumerState<MenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  bool _isAvailable = true;
  bool _isVeg = true;
  String _selectedType = '';
  List<String> _types = [];

  @override
  void initState() {
    super.initState();
    if (widget.menuItem != null) {
      _nameController.text = widget.menuItem!.name;
      _priceController.text = widget.menuItem!.price.toString();
      _isAvailable = widget.menuItem!.isAvailable;
      _isVeg = widget.menuItem!.isVeg;
      _selectedType = widget.menuItem!.type;
    }
    _fetchTypes();
  }

  Future<void> _fetchTypes() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.sellerId)
        .collection('types')
        .get();
    setState(() {
      _types = snapshot.docs.map((doc) => doc.id).toList();
    });
  }

  Future<void> _addType(String type) async {
    await FirebaseFirestore.instance
        .collection('sellers')
        .doc(widget.sellerId)
        .collection('types')
        .doc(type)
        .set({});
    _fetchTypes();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _saveMenuItem() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final name = _nameController.text.trim();
    final price = double.parse(_priceController.text.trim());
    final isAvailable = _isAvailable;
    final isVeg = _isVeg;
    final type = _selectedType;

    final newMenuItem = MenuItem(
      id: widget.menuItem?.id ??
          FirebaseFirestore.instance
              .collection('sellers')
              .doc(widget.sellerId)
              .collection('menuItems')
              .doc()
              .id,
      name: name,
      price: price,
      isAvailable: isAvailable,
      sellerId: widget.sellerId,
      isVeg: isVeg,
      type: type,
    );

    final sellerService = ref.read(sellerProvider);

    if (widget.menuItem == null) {
      // Check if the item already exists
      final existingItems = await FirebaseFirestore.instance
          .collection('sellers')
          .doc(widget.sellerId)
          .collection('menuItems')
          .where('name', isEqualTo: name)
          .get();

      if (existingItems.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item with this name already exists.')),
        );
        return;
      }
      await sellerService.addMenuItem(widget.sellerId, newMenuItem);
    } else {
      await sellerService.updateMenuItem(widget.sellerId, newMenuItem);
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.menuItem == null ? 'Add Menu Item' : 'Edit Menu Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: 'Price',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                      borderSide: BorderSide(color: Colors.blue.shade900),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a price';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text('Veg/Non-Veg:'),
                    const SizedBox(width: 16),
                    RectangularRadioButton<bool>(
                      value: true,
                      groupValue: _isVeg,
                      onChanged: (value) {
                        setState(() {
                          _isVeg = value!;
                        });
                      },
                      activeColor: Colors.green,
                      inactiveColor: Colors.blue.shade900,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Veg',
                      style: TextStyle(
                        color: _isVeg ? Colors.green : Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    RectangularRadioButton<bool>(
                      value: false,
                      groupValue: _isVeg,
                      onChanged: (value) {
                        setState(() {
                          _isVeg = value!;
                        });
                      },
                      activeColor: Colors.red,
                      inactiveColor: Colors.blue.shade900,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Non-Veg',
                      style: TextStyle(
                        color: !_isVeg ? Colors.red : Colors.blue.shade900,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Available:'),
                    const SizedBox(width: 8),
                    RectangularSwitch(
                      value: _isAvailable,
                      onChanged: (value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField2<String>(
                        value: _selectedType.isNotEmpty ? _selectedType : null,
                        decoration: InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.blue.shade900),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide(color: Colors.blue.shade900),
                          ),
                        ),
                        items: _types.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select a type';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () async {
                        final typeController = TextEditingController();
                        await showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('Add Type'),
                              content: TextField(
                                controller: typeController,
                                decoration: InputDecoration(
                                  labelText: 'Type',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.blue.shade900),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                    borderSide:
                                        BorderSide(color: Colors.blue.shade900),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final type = typeController.text.trim();
                                    if (type.isNotEmpty) {
                                      _addType(type);
                                    }
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Add'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: screenWidth * 0.24,
                  child: NeoPopButton(
                    color: Colors.blue.shade900,
                    onTapUp: _saveMenuItem,
                    child: const Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 13),
                      child: Center(
                        child: const Text(
                          'Save',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
