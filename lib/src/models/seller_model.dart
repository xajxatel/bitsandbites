class Seller {
  final String id;
  final String shopName;
  final String ownerName;
  final String location;
  final String phone;
  final String email;
  final bool isOpen;
  final List<String> cuisines;
  final String avatar;
  final String upiId;
  final String upiName;

  Seller({
    required this.id,
    required this.shopName,
    required this.ownerName,
    required this.location,
    required this.phone,
    required this.email,
    required this.isOpen,
    required this.cuisines,
    required this.avatar,
    required this.upiId,
    required this.upiName,
  });

  factory Seller.fromMap(Map<String, dynamic> map, String documentId) {
    return Seller(
      id: documentId,
      shopName: map['shopName'] ?? '',
      ownerName: map['ownerName'] ?? '',
      location: map['location'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      isOpen: map['isOpen'] ?? false,
      cuisines: List<String>.from(map['cuisines'] ?? []),
      avatar: map['avatar'] ?? 'assets/images/avatar1.png',
      upiId: map['upiId'] ?? '',
      upiName: map['upiName'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'shopName': shopName,
      'ownerName': ownerName,
      'location': location,
      'phone': phone,
      'email': email,
      'isOpen': isOpen,
      'cuisines': cuisines,
      'avatar': avatar,
      'upiId': upiId,
      'upiName': upiName,
    };
  }
}
