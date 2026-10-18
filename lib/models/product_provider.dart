import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'product.dart';

class ProductProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance.collection('products');
  List<Product> _products = [];
  bool _isLoading = true;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  ProductProvider() {
    // بضل يسمع أي تعديل بصير من أي تلفون
    _db.snapshots().listen((snapshot) {
      _products = snapshot.docs.map((doc) => Product.fromMap(doc.data(), doc.id)).toList();
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> addProduct(Product p) async {
    await _db.doc(p.id).set(p.toMap());
  }

  Future<void> updateProduct(Product p) async {
    await _db.doc(p.id).update(p.toMap());
  }
  

  // هون صلحناها - بتاخد String id وهاد اللي كان عامل Error عندك
  Future<void> removeProduct(String id) async {
    await _db.doc(id).delete();
  }

  Future<void> deleteProduct(String id) => removeProduct(id);
}