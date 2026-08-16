import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  bool _isSinhala = false;
  bool get isSinhala => _isSinhala;

  void toggleLanguage() {
    _isSinhala = !_isSinhala;
    notifyListeners();
  }

  final List<Map<String, dynamic>> _cartItems = [];
  List<Map<String, dynamic>> get cartItems => _cartItems;

  void addToCart(Map<String, dynamic> item) {
    _cartItems.add(item);
    notifyListeners();
  }

  void removeOneItemByEnName(String nameEn) {
    int index = _cartItems.lastIndexWhere((element) => element['nameEn'] == nameEn);
    if (index != -1) {
      _cartItems.removeAt(index);
      notifyListeners();
    }
  }

  void removeAllByEnName(String nameEn) {
    _cartItems.removeWhere((element) => element['nameEn'] == nameEn);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  double get cartSubTotal {
    return _cartItems.fold(0, (sum, item) => sum + (double.tryParse(item['price'].toString()) ?? 0.0));
  }

  int _points = 350;
  int get points => _points;

  void updatePoints(int newPoints) {
    _points = newPoints;
    notifyListeners();
  }
}