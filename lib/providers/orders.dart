import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order_item.dart';

class Orders with ChangeNotifier {
  final List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    _orders.add(OrderItem(
      id: DateTime.now().toString(),
      amount: total,
      products: cartProducts,
      datetime: DateTime.now(),
    ));

    notifyListeners();
  }
}
