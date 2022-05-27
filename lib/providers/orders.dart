import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:shop_app/models/order_item.dart';

import 'package:http/http.dart' as http;

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? _authToken;
  final String? _userId;

  Orders(this._authToken, this._orders, this._userId);

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchData() async {
    var _params = {
      'auth': _authToken,
    };

    final url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders/$_userId.json',
      _params,
    );
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
              price: element['price'],
              imageUrl: element['imageUrl'],
            );
          }).toList(),
          datetime: DateTime.parse(orderData['datetime']),
        ),
      );
    });
    _orders = loadedOrder;
    notifyListeners();
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    var _params = {
      'auth': _authToken,
    };

    final url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/orders/$_userId.json',
      _params,
    );
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
