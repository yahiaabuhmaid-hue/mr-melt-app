import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final String nameAr;
  final double price;
  final String image;
  final String description;
  final String flavor;
  final DateTime? timestamp;

  Product({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.price,
    required this.image,
    required this.description,
    this.flavor = '',
    this.timestamp,
  });

  // عشان الكود القديم اللي بستخدم name يضل شغال
  String get displayName => nameAr.isNotEmpty ? nameAr : name;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'nameAr': nameAr,
      'price': price,
      'image': image,
      'imageUrl': image,
      'description': description,
      'flavor': flavor,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> data, String docId) {
    return Product(
      id: docId,
      name: data['name'] ?? data['nameAr'] ?? '',
      nameAr: data['nameAr'] ?? data['name'] ?? '',
      price: (data['price'] is num)
          ? (data['price'] as num).toDouble()
          : double.tryParse(data['price'].toString()) ?? 0.0,
      image: data['image'] ?? data['imageUrl'] ?? '',
      description: data['description'] ?? '',
      flavor: data['flavor'] ?? '',
      timestamp: data['timestamp'] is Timestamp
          ? (data['timestamp'] as Timestamp).toDate()
          : null,
    );
  }
}

