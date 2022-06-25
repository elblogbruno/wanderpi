import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:wp_frontend/models/token.dart';

import '../models/user.dart';

class SharedApi {

  static deleteUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('user');
  }

  static Future<SharedPreferences> getInstance() async {
    return SharedPreferences.getInstance();
  }

  static saveUser(User user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('user', jsonEncode(user.toJson()));
  }

  static Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString('user');

    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    } else {
      return null;
    }
  }

  static deleteToken() async {
    final SharedPreferences prefs = await SharedApi.getInstance();
    prefs.remove('token');
  }

  static saveToken(Token token) async {
    final SharedPreferences prefs = await SharedApi.getInstance();
    prefs.setString('token', token.access_token);
  }

  static Future<String?> getToken() async {
    final SharedPreferences prefs = await SharedApi.getInstance();
    return prefs.getString('token');
  }

}

