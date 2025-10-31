import 'package:flutter/material.dart';
import '../../data/models/auth_model.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/user_service.dart';
import '../../data/datasources/local/local_storage.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  late LocalStorage _localStorage;
  
  UserData? _currentUser;
  String? _token;
  bool _isLoading = false;
  String? _error;

  UserData? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null && _currentUser != null;

  AuthProvider() {
    _initStorage();
  }

  Future<void> _initStorage() async {
    _localStorage = await LocalStorage.create();
    await checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    final savedToken = _localStorage.getToken();
    if (savedToken != null) {
      _token = savedToken;
      // Try to fetch user data with saved token
      await fetchUserData();
      notifyListeners();
    }
  }

  Future<void> fetchUserData() async {
    if (_token == null) return;

    try {
      final userData = await _userService.getUserSettings(_token!);
      _currentUser = userData;
      notifyListeners();
    } catch (e) {
      // If token is invalid, clear auth
      if (e.toString().contains('Authentication required')) {
        await logout();
      }
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.login(email, password);
      _token = response.token;
      _currentUser = response.user;

      await _localStorage.saveToken(response.token);

      // Fetch additional user data after successful login
      await fetchUserData();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String childName,
    int? childAge,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _authService.register(
        email: email,
        password: password,
        childName: childName,
        childAge: childAge,
      );
      
      _token = response.token;
      _currentUser = response.user;
      
      await _localStorage.saveToken(response.token);
      
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> completeOnboarding() async {
    if (_token == null) return;
    
    try {
      await _authService.completeOnboarding(_token!);
      if (_currentUser != null) {
        _currentUser = UserData(
          id: _currentUser!.id,
          email: _currentUser!.email,
          childName: _currentUser!.childName,
          childAge: _currentUser!.childAge,
          firstLogin: false,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _localStorage.clearAuth();
    _token = null;
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}