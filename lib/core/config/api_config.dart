import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // URL base de la API - se obtiene de las variables de entorno
  // Por defecto usa localhost:4000 si no está configurado
  static String get baseUrl {
    return dotenv.env['BASE_URL'] ?? 'http://localhost:4000';
  }
  
  // ==================== AUTENTICACIÓN ====================
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  
  // ==================== USUARIO ====================
  static const String apiMe = '/api/me';
  
  // ==================== WALLET Y BALANCE ====================
  static const String apiWallet = '/api/me/wallet';
  static const String apiBalance = '/api/me/balance';
  
  // ==================== TRANSACCIONES ====================
  static const String apiTransactions = '/api/me/transactions';
  static const String apiSend = '/api/me/send';
  
  // ==================== STAKING ====================
  static const String apiStakes = '/api/me/stakes';
  static String stakeClose(String stakeId) => '$apiStakes/$stakeId/close';
  
  // ==================== NOTICIAS (SOLO LECTURA PARA USUARIOS) ====================
  static const String apiNews = '/api/news';
  static const String apiNewsCategories = '/api/news/categories';
  
  // ==================== COMPRAS USDT/BS ====================
  static const String apiPurchasesPrice = '/api/purchases/price';
  static const String apiPurchases = '/api/purchases';
  static const String apiPurchasesQr = '/api/purchases/qr';
  static const String apiPurchasesMe = '/api/purchases/me';
  static String apiPurchasesMeById(String purchaseId) => '$apiPurchasesMe/$purchaseId';
  
  // ==================== PRECIOS BINANCE P2P (PÚBLICO) ====================
  static const String apiP2pUsdtBuyAvg = '/api/p2p/usdt/buy/avg';
  
  // ==================== CONFIGURACIÓN ====================
  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

