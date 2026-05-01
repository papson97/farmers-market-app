import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = true;
  Map<String, dynamic>? _user;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;

  AuthProvider() {
    checkAuth();
  }

  Future<void> checkAuth() async {
    final token = await ApiService.getToken();
    _isAuthenticated = token != null;
    _isLoading = false;
    notifyListeners();
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await ApiService.post('/login', {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await ApiService.saveToken(data['token']);
        _user = data['user'];
        _isAuthenticated = true;
        notifyListeners();
        return null;
      } else {
        final data = jsonDecode(response.body);
        return data['message'] ?? 'Erreur de connexion';
      }
    } catch (e) {
      return 'Erreur réseau : $e';
    }
  }

  Future<void> logout() async {
    await ApiService.removeToken();
    _isAuthenticated = false;
    _user = null;
    notifyListeners();
  }
}