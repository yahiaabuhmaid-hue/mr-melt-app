import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  OrderItem({required this.productId, required this.name, required this.quantity, required this.price});

  Map<String, dynamic> toMap() => {'productId': productId, 'name': name, 'quantity': quantity, 'price': price};
  factory OrderItem.fromMap(Map<String,dynamic> m) => OrderItem(productId: m['productId'], name: m['name'], quantity: m['quantity'], price: (m['price'] as num).toDouble());
}

class CustomerOrder {
  final String id;
  final String customerName;
  final String phone;
  final String address;
  final List<OrderItem> items;
  final double total;
  final Timestamp timestamp;
  final String status; // pending, accepted

  CustomerOrder({required this.id, required this.customerName, required this.phone, required this.address, required this.items, required this.total, required this.timestamp, this.status = 'pending'});

  Map<String,dynamic> toMap() => {
    'customerName': customerName,
    'phone': phone,
    'address': address,
    'items': items.map((e)=>e.toMap()).toList(),
    'total': total,
    'timestamp': FieldValue.serverTimestamp(),
    'status': status,
  };

  factory CustomerOrder.fromMap(Map<String,dynamic> map, String docId) {
    return CustomerOrder(
      id: docId,
      customerName: map['customerName']?? '',
      phone: map['phone']?? '',
      address: map['address']?? '',
      items: (map['items'] as List).map((e)=> OrderItem.fromMap(Map<String,dynamic>.from(e))).toList(),
      total: (map['total'] as num).toDouble(),
      timestamp: map['timestamp']?? Timestamp.now(),
      status: map['status']?? 'pending',
    );
  }
}


