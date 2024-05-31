import 'package:cloud_firestore/cloud_firestore.dart';

class FoodOutlet {
  final String id;
  final String name;
  final String owner;
  final String location;
  final List<String> cuisines;
  final bool isOpen;

  FoodOutlet({
    required this.id,
    required this.name,
    required this.owner,
    required this.location,
    required this.cuisines,
    required this.isOpen,
  });

  factory FoodOutlet.fromFirestore(DocumentSnapshot doc) {
    Map data = doc.data() as Map;
    return FoodOutlet(
      id: doc.id,
      name: data['name'] ?? '',
      owner: data['owner'] ?? '',
      location: data['location'] ?? '',
      cuisines: List<String>.from(data['cuisines'] ?? []),
      isOpen: data['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'owner': owner,
      'location': location,
      'cuisines': cuisines,
      'isOpen': isOpen,
    };
  }
}
