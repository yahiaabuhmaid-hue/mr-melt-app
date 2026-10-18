import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'order.dart';

class OrderProvider with ChangeNotifier {
  final _db = FirebaseFirestore.instance.collection('orders');
  List<CustomerOrder> _orders = [];

  List<CustomerOrder> get orders => _orders;
  int get newCount => _orders.where((o) => o.status == 'pending').length;

  OrderProvider() {
    // بدون orderBy عشان ما يطلب index - الترتيب بصير محلي
    _db.snapshots().listen((snap) {
      _orders = snap.docs.map((d) => CustomerOrder.fromMap(d.data(), d.id)).toList();
      _orders.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      notifyListeners();
    });
  }

  Stream<List<CustomerOrder>> get ordersStream {
    return _db.snapshots().map((snap) {
      final list = snap.docs.map((d) => CustomerOrder.fromMap(d.data(), d.id)).toList();
      list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return list;
    });
  }

  Future<void> addOrder(CustomerOrder order) async {
    await _db.add(order.toMap());
  }

  // دالة واحدة فقط - كانت مكررة مرتين عندك
  Future<void> updateStatus(String id, String status) async {
    await _db.doc(id).update({'status': status});
    notifyListeners();
  }

  Future<void> deleteOrder(String id) async {
    await _db.doc(id).delete();
    notifyListeners();
  }
}


