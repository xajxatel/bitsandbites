class MenuItem {
  final String id;
  final String name;
  final double price;
  final bool isAvailable;
  final String sellerId;
  final bool isVeg;
  final String type;
  final double rating;
  final int numberOfRatings;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.isAvailable,
    required this.sellerId,
    required this.isVeg,
    required this.type,
    this.rating = 0.0,
    this.numberOfRatings = 0,
  });

  factory MenuItem.fromMap(Map<String, dynamic> map, String documentId) {
    return MenuItem(
      id: documentId,
      name: map['name'] ?? '',
      price: map['price']?.toDouble() ?? 0.0,
      isAvailable: map['isAvailable'] ?? true,
      sellerId: map['sellerId'] ?? '',
      isVeg: map['isVeg'] ?? true,
      type: map['type'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      numberOfRatings: map['numberOfRatings']?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
      'isAvailable': isAvailable,
      'sellerId': sellerId,
      'isVeg': isVeg,
      'type': type,
      'rating': rating,
      'numberOfRatings': numberOfRatings,
    };
  }

  MenuItem copyWith({
    String? id,
    String? name,
    double? price,
    bool? isAvailable,
    String? sellerId,
    bool? isVeg,
    String? type,
    double? rating,
    int? numberOfRatings,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      sellerId: sellerId ?? this.sellerId,
      isVeg: isVeg ?? this.isVeg,
      type: type ?? this.type,
      rating: rating ?? this.rating,
      numberOfRatings: numberOfRatings ?? this.numberOfRatings,
    );
  }
}
