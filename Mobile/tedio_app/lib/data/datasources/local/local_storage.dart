import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_model.dart';

class LocalStorage {
  static const String _userKey = 'cached_user';
  static const String _tokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  
  final SharedPreferences _prefs;
  
  LocalStorage(this._prefs);
  
  static Future<LocalStorage> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalStorage(prefs);
  }

  Future<bool> saveUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      return await _prefs.setString(_userKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  UserModel? getUser() {
    try {
      final jsonString = _prefs.getString(_userKey);
      if (jsonString != null) {
        final jsonData = json.decode(jsonString);
        return UserModel.fromJson(jsonData);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteUser() async {
    return await _prefs.remove(_userKey);
  }

  Future<bool> saveToken(String token) async {
    return await _prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs.getString(_tokenKey);
  }

  Future<bool> saveRefreshToken(String refreshToken) async {
    return await _prefs.setString(_refreshTokenKey, refreshToken);
  }

  String? getRefreshToken() {
    return _prefs.getString(_refreshTokenKey);
  }

  Future<bool> clearAuth() async {
    final results = await Future.wait([
      _prefs.remove(_userKey),
      _prefs.remove(_tokenKey),
      _prefs.remove(_refreshTokenKey),
    ]);
    return results.every((result) => result);
  }

  Future<bool> hasValidAuth() async {
    final token = getToken();
    final user = getUser();
    return token != null && user != null;
  }
}