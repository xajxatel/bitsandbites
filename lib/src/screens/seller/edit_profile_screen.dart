import 'package:bitsandbites/src/widgets/rectactangular_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:neopop/neopop.dart';
import '../../providers/seller_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/seller_model.dart';
import 'package:bitsandbites/src/widgets/loading_indicator.dart';

import 'package:unicons/unicons.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final String sellerId;

  const EditProfileScreen({Key? key, required this.sellerId}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _locationController = TextEditingController();
  final _phoneController = TextEditingController();
  final _upiIdController = TextEditingController();
  final _upiReceiverNameController = TextEditingController();
  List<String> _selectedCuisines = [];
  String _selectedAvatar = 'assets/images/avatar1.png'; // Default avatar
  final List<String> _cuisineOptions = [
    'Italian',
    'Chinese',
    'North Indian',
    'Sandwich',
    'Rolls',
    'Parathas',
    'Chaat',
    'South Indian',
    'Fast Food',
  ];
  bool _isInitialized = false;

  @override
  void dispose() {
    _shopNameController.dispose();
    _ownerNameController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _upiIdController.dispose();
    _upiReceiverNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final updatedSeller = Seller(
      avatar: _selectedAvatar,
      id: widget.sellerId,
      shopName: _shopNameController.text.trim(),
      ownerName: _ownerNameController.text.trim(),
      location: _locationController.text.trim(),
      phone: _phoneController.text.trim(),
      email: '', // This field will be ignored in the update
      isOpen: true, // keep the current status unchanged
      cuisines: _selectedCuisines,
      upiId: _upiIdController.text.trim(), // Add UPI ID
      upiName: _upiReceiverNameController.text.trim(), // Add UPI Receiver Name
    );

    await ref.read(sellerProvider).updateSeller(widget.sellerId, updatedSeller);

    Navigator.of(context).pop();
  }

  void _initializeControllers(Seller seller) {
    if (!_isInitialized) {
      _shopNameController.text = seller.shopName;
      _ownerNameController.text = seller.ownerName;
      _locationController.text = seller.location;
      _phoneController.text = seller.phone;
      _selectedCuisines = List.from(seller.cuisines);
      _selectedAvatar = seller.avatar;
      _upiIdController.text = seller.upiId; // Initialize UPI ID
      _upiReceiverNameController.text =
          seller.upiName; // Initialize UPI Receiver Name
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sellerStream = ref.watch(sellerDocProvider(widget.sellerId));
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: sellerStream.when(
          data: (seller) {
            _initializeControllers(seller);

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _shopNameController,
                      decoration: InputDecoration(
                        labelText: 'Shop Name',
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
                          return 'Please enter a shop name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(
                        labelText: 'Owner Name',
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
                          return 'Please enter an owner name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        labelText: 'Location',
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
                          return 'Please enter a location';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.blue.shade900),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.blue.shade900),
                        ),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a phone number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _upiIdController,
                      decoration: InputDecoration(
                        labelText: 'UPI ID',
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
                          return 'Please enter a UPI ID';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _upiReceiverNameController,
                      decoration: InputDecoration(
                        labelText: 'UPI Receiver Name',
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
                          return 'Please enter a UPI receiver name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Type of Cuisine',
                        style: GoogleFonts.inconsolata(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: _cuisineOptions.map((cuisine) {
                        return FilterChip(
                          label: Text(cuisine),
                          selected: _selectedCuisines.contains(cuisine),
                          onSelected: (isSelected) {
                            setState(() {
                              if (isSelected) {
                                _selectedCuisines.add(cuisine);
                              } else {
                                _selectedCuisines.remove(cuisine);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Select an avatar',
                        style: GoogleFonts.inconsolata(
                          fontSize: screenWidth * 0.05,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6.0,
                      runSpacing: 6.0,
                      children: List.generate(7, (index) {
                        final avatarPath =
                            'assets/images/avatar${index + 1}.png';
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedAvatar = avatarPath;
                            });
                          },
                          child: CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.blue.shade900,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundImage: AssetImage(avatarPath),
                              backgroundColor: _selectedAvatar == avatarPath
                                  ? Colors.blue[100]
                                  : Colors.white,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: screenWidth * 0.23,
                      child: NeoPopButton(
                        color: Colors.blue.shade900,
                        onTapUp: _saveProfile,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Center(
                            child: Text(
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
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (error, stack) => Center(child: Text('Error: $error')),
        ),
      ),
    );
  }
}
