import 'package:flutter/material.dart';
import 'product.dart';

class CartItem {
  final Product product;
  int quantity;
  CartItem({required this.product, this.quantity = 1});
}

class CartModel extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;
  double get totalAmount => _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));
  int get totalCount => _items.fold(0, (sum, item) => sum + item.quantity);
  int get count => totalCount;

  // الجديد
  void addItem(Product product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    notifyListeners();
  }

  // الأسماء القديمة اللي بدور عليها product_card
  void add(Product product) => addItem(product);

  int quantity(String productId) {
    final i = _items.indexWhere((e) => e.product.id == productId);
    return i >= 0? _items[i].quantity : 0;
  }

  void removeOne(Product product) {
    final index = _items.indexWhere((e) => e.product.id == product.id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}