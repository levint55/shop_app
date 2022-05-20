import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order_item.dart';

import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchData() async {
    final url = Uri.https(
        'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/orders.json');
    final response = await http.get(url);
    final List<OrderItem> loadedOrder = [];
    final Map<String, dynamic>? extractedData =
        json.decode(response.body) as Map<String, dynamic>?;

    if (extractedData == null) {
      return;
    }

    extractedData.forEach((orderId, orderData) {
      loadedOrder.add(
        OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>).map((element) {
            return CartItem(
                id: element['id'],
                title: element['title'],
                quantity: element['quantity'],
                price: element['price']);
          }).toList(),
          datetime: DateTime.parse(orderData['datetime']),
        ),
      );
    });
    _orders = loadedOrder;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.https(
        'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/orders.json');
    final timestamp = DateTime.now();
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'datetime': timestamp.toIso8601String(),
            'products': cartProducts
                .map((e) => {
                      'id': e.id,
                      'title': e.title,
                      'quantity': e.quantity,
                      'price': e.price
                    })
                .toList(),
          }));
      _orders.add(OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        datetime: timestamp,
      ));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
