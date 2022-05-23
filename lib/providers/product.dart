import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFavorite(bool newValue) {
    isFavorite = newValue;
    notifyListeners();
  }

  Future<void> toggleFavorite(String? token, String? userId) async {
    var _params = {
      'auth': token,
    };

    final url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/userFavorites/$userId/$id.json',
      _params,
    );

    final oldValue = isFavorite;
    isFavorite = !isFavorite;

    _setFavorite(isFavorite);
    notifyListeners();

    try {
      final response =
          await http.put(url, body: json.encode({'isFavorite': isFavorite}));

      if (response.statusCode >= 400) {
        _setFavorite(oldValue);
        throw HttpException('Could not favorite product.');
      }
    } catch (e) {
      _setFavorite(oldValue);
      throw HttpException('Error.');
    }
  }
}
