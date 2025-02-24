import 'package:flutter/material.dart';

class CartItem {
  final String service;
  final int price;
  int quantity; // เพิ่มตัวแปร quantity

  CartItem({required this.service, required this.price, this.quantity = 1});
}

class CartService with ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => [..._items];

  int get totalPrice => _items.fold(0, (sum, item) => sum + (item.price * item.quantity));

  // ✅ ถ้าบริการเดิมมีอยู่แล้ว จะเพิ่มจำนวน ไม่เพิ่มรายการใหม่
  void addItem(String service, int price, int quantity) {
    final index = _items.indexWhere((item) => item.service == service);

    if (index != -1) {
      _items[index].quantity += quantity; // เพิ่มจำนวน
    } else {
      _items.add(CartItem(service: service, price: price, quantity: quantity));
    }
    notifyListeners();
  }

  // ✅ อัปเดตจำนวน (เพิ่มหรือลด)
  void updateQuantity(String service, int newQuantity) {
    final index = _items.indexWhere((item) => item.service == service);
    if (index != -1) {
      if (newQuantity > 0) {
        _items[index].quantity = newQuantity;
      } else {
        _items.removeAt(index); // ถ้าจำนวนเป็น 0 ให้ลบออก
      }
      notifyListeners();
    }
  }

  void removeItem(String service) {
    _items.removeWhere((item) => item.service == service);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
