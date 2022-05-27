import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class Products with ChangeNotifier {
  List<Product> _items = [];
  final String? _authToken;
  final String? _userId;

  Products(this._authToken, this._items, this._userId);

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((element) => element.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchData([bool filterByUser = false]) async {
    var _params = {
      'auth': _authToken,
    };

    if (filterByUser) {
      _params['orderBy'] = '"creatorId"';
      _params['equalTo'] = '"$_userId"';
    }

    var url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/products.json',
      _params,
    );

    try {
      final response = await http.get(url);
      final Map<String, dynamic>? data =
          json.decode(response.body) as Map<String, dynamic>?;

      if (data == null) {
        return;
      }

      if (response.statusCode >= 400) {
        throw HttpException('Error');
      }

      url = Uri.https(
        'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/userFavorites/$_userId.json',
        _params,
      );
      final favoritesResponse = await http.get(url);
      final favoritesData = json.decode(favoritesResponse.body);

      final List<Product> loadedProduct = [];
      data.forEach((productId, prodData) {
        loadedProduct.add(Product(
          id: productId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite: favoritesData == null
              ? false
              : favoritesData[productId] == null
                  ? false
                  : favoritesData[productId]['isFavorite'],
        ));
      });
      _items = loadedProduct;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addProduct(Product product) async {
    var _params = {
      'auth': _authToken,
    };
    final url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/products.json',
      _params,
    );

    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': _userId,
          }));

      final Product newProduct = Product(
        description: product.description,
        id: json.decode(response.body)['name'],
        imageUrl: product.imageUrl,
        price: product.price,
        title: product.title,
      );
      _items.add(newProduct);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    var _params = {
      'auth': _authToken,
    };

    final prodIndex = _items.indexWhere((element) => element.id == id);
    if (prodIndex >= 0) {
      final url = Uri.https(
        'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
        '/products/$id.json',
        _params,
      );

      await http.patch(url,
          body: json.encode({
            'title': newProduct.title,
            'description': newProduct.description,
            'imageUrl': newProduct.imageUrl,
            'price': newProduct.price,
          }));
      _items[prodIndex] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    var _params = {
      'auth': _authToken,
    };

    final url = Uri.https(
      'flutter-shop-app-be36b-default-rtdb.asia-southeast1.firebasedatabase.app',
      '/products/$id.json',
      _params,
    );

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    var existingProduct = _items[existingProductIndex];

    _items.removeAt(existingProductIndex);
    notifyListeners();

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product.');
    }
  }
}
