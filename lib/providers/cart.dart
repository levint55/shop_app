import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/cart_item.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Cart with ChangeNotifier {
  Map<String, dynamic> _items = {};
  final String? _authToken;
  final String? _userId;

  Cart(this._authToken, this._userId);

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  Future fetchData() async {
    var _params = {
      'auth': _authToken,
    };

    var url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/carts/$_userId.json',
      _params,
    );

    try {
      final response = await http.get(url);

      final Map<String, dynamic> data = json.decode(response.body);

      Map<String, dynamic> temp = {};
      data.forEach(
        (key, value) {
          temp[key] = CartItem(
            id: key,
            title: value['title'],
            quantity: value['quantity'],
            price: value['price'],
            imageUrl: value['imageUrl'],
          );
        },
      );
      _items = temp;

      if (response.statusCode >= 400) {
        throw HttpException('Error');
      }
    } catch (e) {
      rethrow;
    }
  }

  void removeAllItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  Future addItem(
    String productId,
    double price,
    String title,
    String imageUrl,
  ) async {
    var _params = {
      'auth': _authToken,
    };

    var newRecord = {};

    if (_items.containsKey(productId)) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity + 1,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
        ),
      );

      newRecord = {
        'title': _items[productId]!.title,
        'quantity': _items[productId]!.quantity,
        'price': _items[productId]!.price,
        'imageUrl': _items[productId]!.imageUrl,
      };

      try {
        var url = Uri.https(
          'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/carts/$_userId/$productId.json',
          _params,
        );
        final response = await http.patch(url, body: json.encode(newRecord));

        notifyListeners();
      } catch (e) {}
    } else {
      _items.putIfAbsent(
        productId,
        () => CartItem(
          id: DateTime.now().toString(),
          title: title,
          quantity: 1,
          price: price,
          imageUrl: imageUrl,
        ),
      );
      newRecord = {
        'title': _items[productId]!.title,
        'quantity': 1,
        'price': _items[productId]!.price,
        'imageUrl': _items[productId]!.imageUrl,
        'productId': productId
      };

      try {
        var url = Uri.https(
          'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
          '/carts/$_userId.json',
          _params,
        );

        final response = await http.post(url, body: json.encode(newRecord));

        notifyListeners();
      } catch (e) {}
    }
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          id: existingCartItem.id,
          title: existingCartItem.title,
          quantity: existingCartItem.quantity - 1,
          price: existingCartItem.price,
          imageUrl: existingCartItem.imageUrl,
        ),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }
}
