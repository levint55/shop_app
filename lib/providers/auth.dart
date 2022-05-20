import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/models/http_exception.dart';

class Auth with ChangeNotifier {
  String? _token;
  DateTime? _expiryDate;
  String? _userId;
  static String API_KEY = 'AIzaSyAGuWUAo2B_csiB5yxjmjw6Vx5-lEKySQw';

  bool get isAuth {
    return token != null;
  }

  String? get token {
    if (_expiryDate != null && _token != null) {
      if (_expiryDate!.isAfter(DateTime.now())) {
        return _token;
      }
    }
    return null;
  }

  Future _authenticate(
      String? email, String? password, String? urlSegment) async {
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=$API_KEY');

    try {
      final response = await http.post(
        url,
        body: json.encode(
          {
            'email': email,
            'password': password,
            'returnSecureToken': true,
          },
        ),
      );

      final responseData = json.decode(response.body);

      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future login(String? email, String? password) async {
    return _authenticate(email, password, 'signInWithPassword');
  }

  Future signUp(String? email, String? password) async {
    return _authenticate(email, password, 'signUp');
  }
}
