import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;
import '../config/api_config.dart';

class ApiService {
  late Dio _dio;
  static final ApiService _instance = ApiService._internal();
  
  factory ApiService() => _instance;
  
  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
    
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          // Limpiar headers null
          options.headers.removeWhere((key, value) => value == null);
          
          // Limpiar datos null del body antes de enviar
          if (options.data != null) {
            if (options.data is Map) {
              try {
                final cleanedData = _removeNullValues(options.data as Map<String, dynamic>);
                // Asegurar que el mapa no esté vacío después de limpiar
                if (cleanedData.isNotEmpty) {
                  options.data = cleanedData;
                }
                // Verificar que no haya nulls en los valores
                final hasNulls = cleanedData.values.any((v) => v == null);
                if (hasNulls) {
                  developer.log('WARNING: Se encontraron valores null en los datos después de limpiar', name: 'ApiService');
                }
              } catch (e) {
                developer.log('Error al limpiar datos del request: $e', name: 'ApiService', error: e);
                // Continuar con los datos originales si hay error
              }
            } else if (options.data is List) {
              // Limpiar nulls de listas
              try {
                final list = options.data as List;
                options.data = list.where((item) => item != null).toList();
              } catch (e) {
                developer.log('Error al limpiar lista del request: $e', name: 'ApiService', error: e);
              }
            }
          }
          
          // Asegurar que Content-Type esté configurado correctamente para POST/PUT/PATCH
          if (options.data != null && 
              (options.method == 'POST' || options.method == 'PUT' || options.method == 'PATCH') &&
              options.headers['Content-Type'] == null) {
            options.headers['Content-Type'] = 'application/json';
          }
          
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString('auth_token');
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

        } catch (e) {
          developer.log('Error al procesar request: $e', name: 'ApiService', error: e);
          // Continuar con la petición aunque haya error al obtener el token
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        try {
          if (error.response?.statusCode == 401) {
            _clearAuth();
          }
        } catch (e) {
          developer.log('Error al limpiar auth: $e', name: 'ApiService', error: e);
          // Continuar con el manejo del error aunque haya fallado la limpieza
        }
        return handler.next(error);
      },
    ));
  }
  
  Future<void> _clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }
  
  // Función para limpiar valores null de los datos antes de enviarlos
  // Evita enviar valores null que pueden causar errores en el servidor
  Map<String, dynamic> _removeNullValues(Map<String, dynamic> data) {
    final cleaned = <String, dynamic>{};
    data.forEach((key, value) {
      // Solo eliminar si es null, no si es string vacío u otros valores
      if (value != null) {
        if (value is Map) {
          cleaned[key] = _removeNullValues(value as Map<String, dynamic>);
        } else if (value is List) {
          // Mantener listas aunque estén vacías, pero limpiar nulls dentro
          cleaned[key] = value.map((item) {
            if (item is Map) {
              return _removeNullValues(item as Map<String, dynamic>);
            }
            return item;
          }).toList();
        } else {
          // Asegurar que no se envíen valores que puedan causar problemas
          // Convertir tipos problemáticos a strings si es necesario
          cleaned[key] = value;
        }
      }
    });
    return cleaned;
  }
  
  // ==================== AUTENTICACIÓN ====================
  
  /// Registra un nuevo usuario
  /// 
  /// Requiere: email, password, firstName, lastName
  Future<Response> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    // Validar campos requeridos
    if (email.isEmpty || password.isEmpty || firstName.isEmpty || lastName.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConfig.authRegister),
        error: 'Email, contraseña, nombre y apellido son requeridos',
      );
    }
    
    // Preparar datos asegurándonos de que no haya nulls ni strings vacíos después de trim
    final emailTrimmed = email.trim();
    final firstNameTrimmed = firstName.trim();
    final lastNameTrimmed = lastName.trim();
    
    if (emailTrimmed.isEmpty || firstNameTrimmed.isEmpty || lastNameTrimmed.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConfig.authRegister),
        error: 'Email, nombre y apellido no pueden estar vacíos',
      );
    }
    
    // Crear mapa limpio sin nulls
    final data = <String, dynamic>{
      'email': emailTrimmed,
      'password': password,
      'firstName': firstNameTrimmed,
      'lastName': lastNameTrimmed,
    };
    
    // Limpiar nulls explícitamente antes de enviar
    final cleanedData = _removeNullValues(data);
    
    developer.log('Register request to: ${ApiConfig.baseUrl}${ApiConfig.authRegister}', name: 'ApiService');
    developer.log('Register data (cleaned): $cleanedData', name: 'ApiService');
    
    try {
      final response = await _dio.post(
        ApiConfig.authRegister,
        data: cleanedData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );
      
      developer.log('Register response status: ${response.statusCode}', name: 'ApiService');
      developer.log('Register response data: ${response.data}', name: 'ApiService');
      
      return response;
    } catch (e) {
      developer.log('Register error: $e', name: 'ApiService', error: e);
      if (e is DioException) {
        developer.log('DioException type: ${e.type}', name: 'ApiService');
        developer.log('DioException response: ${e.response?.data}', name: 'ApiService');
        developer.log('DioException statusCode: ${e.response?.statusCode}', name: 'ApiService');
        
        if (e.type == DioExceptionType.connectionError) {
          developer.log('ERROR DE CONEXIÓN:', name: 'ApiService');
          developer.log('  - Verifica que el servidor esté corriendo en: ${ApiConfig.baseUrl}', name: 'ApiService');
          developer.log('  - Para web, el servidor debe tener CORS habilitado', name: 'ApiService');
          developer.log('  - Prueba abrir en el navegador: ${ApiConfig.baseUrl}/auth/register', name: 'ApiService');
        }
      }
      rethrow;
    }
  }
  
  Future<Response> login(String email, String password) async {
    // Validar que email y password no sean null o vacíos
    if (email.isEmpty || password.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConfig.authLogin),
        error: 'Email y contraseña son requeridos',
      );
    }
    
    final emailTrimmed = email.trim();
    if (emailTrimmed.isEmpty) {
      throw DioException(
        requestOptions: RequestOptions(path: ApiConfig.authLogin),
        error: 'Email no puede estar vacío',
      );
    }
    
    // Crear mapa limpio sin nulls
    final data = <String, dynamic>{
      'email': emailTrimmed,
      'password': password,
    };
    
    // Limpiar nulls explícitamente
    final cleanedData = _removeNullValues(data);
    
    return await _dio.post(
      ApiConfig.authLogin,
      data: cleanedData,
      options: Options(
        validateStatus: (status) => status != null && status < 500,
      ),
    );
  }
  
  // User & Wallet
  Future<Response> getMe() async {
    return await _dio.get(ApiConfig.apiMe);
  }
  
  Future<Response> getWallet() async {
    return await _dio.get(ApiConfig.apiWallet);
  }
  
  Future<Response> getBalance() async {
    return await _dio.get(ApiConfig.apiBalance);
  }
  
  /// Actualiza el perfil del usuario
  Future<Response> updateProfile({
    String? bankAccountNumber,
    String? bankEntity,
  }) async {
    final data = _removeNullValues({
      'bankAccountNumber': bankAccountNumber,
      'bankEntity': bankEntity,
    });
    return await _dio.put(ApiConfig.apiMe, data: data);
  }
  
  /// Cambia la contraseña del usuario
  Future<Response> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final data = _removeNullValues({
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    });
    return await _dio.post(ApiConfig.apiMeChangePassword, data: data);
  }
  
  // Transactions
  Future<Response> getTransactions({
    String? source,
    int? limit,
    String? status,
    String? direction,
    String? fingerprint,
  }) async {
    final queryParams = <String, dynamic>{};
    if (source != null) queryParams['source'] = source;
    if (limit != null) queryParams['limit'] = limit;
    if (status != null) queryParams['status'] = status;
    if (direction != null) queryParams['direction'] = direction;
    if (fingerprint != null) queryParams['fingerprint'] = fingerprint;
    
    return await _dio.get(ApiConfig.apiTransactions, queryParameters: queryParams);
  }
  
  /// Envía USDT desde tu wallet a otra dirección TRON
  /// 
  /// Opcionalmente puedes pasar un idempotencyKey para prevenir duplicados
  Future<Response> sendUSDT(String to, String amount, {String? idempotencyKey}) async {
    final headers = <String, dynamic>{};
    if (idempotencyKey != null && idempotencyKey.isNotEmpty) {
      headers['Idempotency-Key'] = idempotencyKey;
    }
    
    final data = _removeNullValues({
      'to': to,
      'amount': amount,
    });
    
    return await _dio.post(
      ApiConfig.apiSend,
      data: data,
      options: Options(headers: headers),
    );
  }
  
  // Staking
  Future<Response> getStakes() async {
    return await _dio.get(ApiConfig.apiStakes);
  }
  
  /// Crea un nuevo stake
  /// 
  /// El dailyRateBp viene del backend, no se envía desde el cliente
  Future<Response> createStake(double amountUsdt) async {
    final data = _removeNullValues({
      'amountUsdt': amountUsdt,
    });
    return await _dio.post(ApiConfig.apiStakes, data: data);
  }
  
  /// Cierra un stake y recibe principal + recompensas
  Future<Response> closeStake(String stakeId) async {
    return await _dio.post(ApiConfig.stakeClose(stakeId));
  }
  
  // ==================== NOTICIAS (SOLO LECTURA PARA USUARIOS) ====================
  
  /// Obtiene todas las noticias (solo lectura para usuarios)
  Future<Response> getNews({int? limit, String? category}) async {
    final queryParams = <String, dynamic>{};
    if (limit != null) queryParams['limit'] = limit;
    if (category != null) queryParams['category'] = category;
    
    return await _dio.get(ApiConfig.apiNews, queryParameters: queryParams);
  }
  
  /// Obtiene todas las categorías disponibles de noticias
  Future<Response> getNewsCategories() async {
    return await _dio.get(ApiConfig.apiNewsCategories);
  }
  
  // Nota: Los métodos createNews, updateNews, deleteNews y getNewsById
  // requieren rol Admin y no están disponibles para usuarios normales
  
  // ==================== COMPRAS USDT/BS ====================
  
  /// Obtiene el precio actual de USDT en BS (Bolívares Soberanos)
  /// 
  /// El precio se calcula como Binance P2P + 0.10 BS adicionales
  Future<Response> getPurchasePrice() async {
    try {
      final response = await _dio.get(ApiConfig.apiPurchasesPrice);
      return response;
    } catch (e) {
      developer.log('Error al obtener precio de compra: $e', name: 'ApiService', error: e);
      if (e is DioException && e.type == DioExceptionType.connectionError) {
        developer.log('ERROR DE CONEXIÓN al obtener precio:', name: 'ApiService');
        developer.log('  - Verifica que el servidor esté corriendo en: ${ApiConfig.baseUrl}', name: 'ApiService');
        developer.log('  - Endpoint: ${ApiConfig.apiPurchasesPrice}', name: 'ApiService');
      }
      rethrow;
    }
  }
  
  /// Crea una nueva solicitud de compra de USDT
  /// 
  /// Requiere: amountUsdt (cantidad de USDT a comprar)
  Future<Response> createPurchase(double amountUsdt) async {
    final data = _removeNullValues({
      'amountUsdt': amountUsdt,
    });
    return await _dio.post(ApiConfig.apiPurchases, data: data);
  }
  
  /// Obtiene la URL del código QR estático para realizar el pago
  Future<Response> getPurchaseQr() async {
    return await _dio.get(ApiConfig.apiPurchasesQr);
  }
  
  /// Obtiene todas las compras del usuario
  /// 
  /// Query params opcionales: status (pending, waiting_payment, completed, rejected)
  Future<Response> getMyPurchases({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    
    return await _dio.get(ApiConfig.apiPurchasesMe, queryParameters: queryParams);
  }
  
  /// Obtiene los detalles de una compra específica del usuario
  Future<Response> getPurchaseById(String purchaseId) async {
    return await _dio.get(ApiConfig.apiPurchasesMeById(purchaseId));
  }
  
  // ==================== RETIROS USDT/BS ====================
  
  /// Obtiene el precio actual de venta de USDT en BS (Bolivianos)
  /// 
  /// El precio se calcula como Binance P2P - 0.10 BS (o similar)
  Future<Response> getWithdrawalPrice() async {
    try {
      final response = await _dio.get(ApiConfig.apiWithdrawalsPrice);
      return response;
    } catch (e) {
      developer.log('Error al obtener precio de retiro: $e', name: 'ApiService', error: e);
      rethrow;
    }
  }
  
  /// Crea una nueva solicitud de retiro de USDT
  /// 
  /// Requiere: amountUsdt (cantidad de USDT a retirar)
  /// El usuario debe tener perfil completado (bankAccountNumber y bankEntity)
  Future<Response> createWithdrawal(double amountUsdt) async {
    final data = _removeNullValues({
      'amountUsdt': amountUsdt,
    });
    return await _dio.post(ApiConfig.apiWithdrawals, data: data);
  }
  
  /// Obtiene todos los retiros del usuario
  /// 
  /// Query params opcionales: status (pending, processing, completed, rejected)
  Future<Response> getMyWithdrawals({String? status}) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    
    return await _dio.get(ApiConfig.apiWithdrawalsMe, queryParameters: queryParams);
  }
  
  /// Obtiene los detalles de un retiro específico del usuario
  Future<Response> getWithdrawalById(String withdrawalId) async {
    return await _dio.get(ApiConfig.apiWithdrawalsMeById(withdrawalId));
  }
  
  // ==================== PRECIOS BINANCE P2P (PÚBLICO - NO REQUIERE TOKEN) ====================
  
  /// Obtiene el precio promedio de compra de USDT en Binance P2P
  /// 
  /// Endpoint público - No requiere autenticación
  /// Query params: asset (default: USDT), fiat (default: BOB), rows (default: 10)
  Future<Response> getP2pBuyAvg({
    String asset = 'USDT',
    String fiat = 'BOB',
    int rows = 10,
  }) async {
    // Crear un cliente sin token para endpoints públicos
    final publicDio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    return await publicDio.get(
      ApiConfig.apiP2pUsdtBuyAvg,
      queryParameters: {
        'asset': asset,
        'fiat': fiat,
        'rows': rows,
      },
    );
  }
  
  // ==================== EXCHANGE RATE (DEPRECATED - USAR getPurchasePrice) ====================
  
  /// @deprecated Usa getPurchasePrice() en su lugar
  /// Obtiene el precio actual de USDT en BS
  Future<Response> getExchangeRate() async {
    // Usar el nuevo endpoint de compras
    return await getPurchasePrice();
  }
}

