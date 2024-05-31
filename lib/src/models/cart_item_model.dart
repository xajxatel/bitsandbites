class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String sellerId;
  final bool isVeg;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.sellerId,
    required this.isVeg,
  });

  CartItem copyWith({
    String? id,
    String? name,
    double? price,
    int? quantity,
    String? sellerId,
    bool? isVeg,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      sellerId: sellerId ?? this.sellerId,
      isVeg: isVeg ?? this.isVeg,
    );
  }

  factory CartItem.fromMap(Map<String, dynamic> data) {
    return CartItem(
      id: data['id'],
      name: data['name'],
      price: data['price'],
      quantity: data['quantity'],
      sellerId: data['sellerId'],
      isVeg: data['isVeg'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'sellerId': sellerId,
      'isVeg': isVeg,
    };
  }
}
