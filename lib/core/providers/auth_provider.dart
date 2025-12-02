import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer' as developer;
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isAuthenticated = false;
  bool _isLoading = false;
  Map<String, dynamic>? _user;
  String? _error;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;

  AuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      if (token != null && token.isNotEmpty && userData != null && userData.isNotEmpty) {
        try {
          _isAuthenticated = true;
          _user = jsonDecode(userData);
          notifyListeners();
        } catch (e) {
          // Si hay error parseando los datos, limpiar
          await _clearStoredAuth();
        }
      }
    } catch (e) {
      // Si hay error, asegurar que no esté autenticado
      _isAuthenticated = false;
      _user = null;
    }
  }
  
  Future<void> _clearStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      _isAuthenticated = false;
      _user = null;
    } catch (e) {
      // Ignorar errores al limpiar
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().register(
        email: normalizedEmail,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );
      
      // Debug: imprimir respuesta
      developer.log('Register response status: ${response.statusCode}', name: 'AuthProvider');
      developer.log('Register response data: ${response.data}', name: 'AuthProvider');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = response.data;
        
        // Manejar diferentes formatos de respuesta
        String? token;
        Map<String, dynamic>? user;
        
        if (responseData is Map) {
          token = responseData['token']?.toString();
          user = responseData['user'] is Map 
              ? Map<String, dynamic>.from(responseData['user'])
              : null;
          
          // Si no hay 'user', intentar otros campos
          if (user == null && responseData['email'] != null) {
            user = {
              'email': responseData['email'],
              'id': responseData['id'] ?? responseData['userId'],
            };
          }
        }
        
        if (token == null || token.isEmpty) {
          _error = 'Error: No se recibió el token de autenticación. Respuesta: ${response.data}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (user != null) {
          await prefs.setString('user_data', jsonEncode(user));
        }
        
        _isAuthenticated = true;
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // Manejar errores del servidor
      final errorData = response.data;
      String errorMsg = 'Error al registrar';
      
      if (errorData is Map) {
        errorMsg = errorData['error'] ?? 
                  errorData['message'] ?? 
                  errorData['msg'] ??
                  errorData.toString();
      } else if (errorData is String) {
        errorMsg = errorData;
      }
      
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      String errorMessage = 'Error al registrar. Intenta nuevamente';
      
      if (e is DioException) {
        if (e.response != null) {
          // Error con respuesta del servidor
          final errorData = e.response?.data;
          if (errorData is Map) {
            errorMessage = errorData['error'] ?? 
                          errorData['message'] ?? 
                          errorData['msg'] ??
                          'Error al registrar';
          } else if (errorData is String) {
            errorMessage = errorData;
          }
          
          // Mensajes específicos según el código de estado
          if (e.response?.statusCode == 400) {
            if (errorMessage.toLowerCase().contains('email') || 
                errorMessage.toLowerCase().contains('ya está') ||
                errorMessage.toLowerCase().contains('already')) {
              errorMessage = 'El email ya está registrado';
            }
          } else if (e.response?.statusCode == 409) {
            errorMessage = 'El email ya está registrado';
          }
        } else {
          // Error de conexión
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Tiempo de espera agotado. Verifica tu conexión';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = 'No se puede conectar al servidor. Verifica que:\n'
                '1. El backend esté corriendo en http://localhost:4000\n'
                '2. El servidor tenga CORS habilitado para web\n'
                '3. No haya firewall bloqueando la conexión';
          }
        }
      } else if (e.toString().contains('Email already registered') ||
                 e.toString().contains('email') && e.toString().contains('already')) {
        errorMessage = 'El email ya está registrado';
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ApiService().login(normalizedEmail, password);
      
      if (response.statusCode == 200) {
        final responseData = response.data;
        
        // Manejar diferentes formatos de respuesta (igual que en register)
        String? token;
        Map<String, dynamic>? user;
        
        if (responseData is Map) {
          token = responseData['token']?.toString();
          user = responseData['user'] is Map 
              ? Map<String, dynamic>.from(responseData['user'])
              : null;
          
          // Si no hay 'user', intentar otros campos
          if (user == null && responseData['email'] != null) {
            user = {
              'email': responseData['email'],
              'id': responseData['id'] ?? responseData['userId'],
            };
          }
        }
        
        if (token == null || token.isEmpty) {
          _error = 'Error: No se recibió el token de autenticación. Respuesta: ${response.data}';
          _isLoading = false;
          notifyListeners();
          return false;
        }
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        if (user != null) {
          await prefs.setString('user_data', jsonEncode(user));
        }
        
        _isAuthenticated = true;
        _user = user;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      
      // Manejar errores del servidor
      final errorData = response.data;
      String errorMsg = 'Error al iniciar sesión';
      
      if (errorData is Map) {
        errorMsg = errorData['error'] ?? 
                  errorData['message'] ?? 
                  errorData['msg'] ??
                  errorData.toString();
      } else if (errorData is String) {
        errorMsg = errorData;
      }
      
      _error = errorMsg;
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      String errorMessage = 'Credenciales inválidas. Intenta nuevamente';
      
      if (e is DioException) {
        if (e.response != null) {
          final errorData = e.response?.data;
          if (errorData is Map) {
            errorMessage = errorData['error'] ?? 
                          errorData['message'] ?? 
                          errorData['msg'] ??
                          'Credenciales inválidas';
          } else if (errorData is String) {
            errorMessage = errorData;
          }
        } else {
          if (e.type == DioExceptionType.connectionTimeout || 
              e.type == DioExceptionType.receiveTimeout) {
            errorMessage = 'Tiempo de espera agotado. Verifica tu conexión';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = 'Error de conexión. Verifica que el servidor esté disponible';
          }
        }
      }
      
      _error = errorMessage;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    await _clearStoredAuth();
    _isLoading = false;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

