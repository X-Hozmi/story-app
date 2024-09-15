import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_app/data/model/serialization/token.dart';
import 'package:story_app/data/model/serialization/user.dart';

class AuthRepository {
  final String stateKey = "state";
  final String userKey = "user";
  final String userToken = "token";

  Future<bool> isLoggedIn() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.getBool(stateKey) ?? false;
  }

  Future<bool> login() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setBool(stateKey, true);
  }

  Future<bool> logout() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setBool(stateKey, false);
  }

  Future<bool> saveUser(User user) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userKey, json.encode(user.toJson()));
  }

  Future<bool> saveToken(Token token) async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userToken, json.encode(token.toJson()));
  }

  Future<bool> deleteUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userKey, "");
  }

  Future<bool> deleteToken() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    return preferences.setString(userToken, "");
  }

  Future<User?> getUser() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    final jsonString = preferences.getString(userKey);
    User? user;
    if (jsonString != null && jsonString.isNotEmpty) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      user = User.fromJson(jsonMap);
    }
    return user;
  }

  Future<Token?> getToken() async {
    final preferences = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    final jsonString = preferences.getString(userToken);
    Token? token;
    if (jsonString != null && jsonString.isNotEmpty) {
      final Map<String, dynamic> jsonMap = json.decode(jsonString);
      token = Token.fromJson(jsonMap);
    }
    return token;
  }

  Future<void> saveSession(Map<String, dynamic> loginResult) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', loginResult['userId']);
    await prefs.setString('name', loginResult['name']);
    await prefs.setString('token', loginResult['token']);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.remove('name');
    await prefs.remove('token');
  }
}
