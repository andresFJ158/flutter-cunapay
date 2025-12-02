import 'package:flutter/material.dart';

/// Sistema de diseño profesional - Paleta de colores CunaPay
/// 
/// Modern Financial App UI - Clean, card-based interface
/// con énfasis en jerarquía y legibilidad
class AppColors {
  // ========== COLORES PRIMARIOS ==========
  
  /// Verde esmeralda (#00A86B) - Color principal para acciones primarias,
  /// tarjetas de información clave e identidad de marca
  static const Color primary = Color(0xFF00A86B);
  
  /// Amarillo lima (#C8E86A) - Color secundario para botones secundarios
  /// y elementos de acento
  static const Color secondary = Color(0xFFC8E86A);
  
  // ========== COLORES DE FONDO ==========
  
  /// Azul marino oscuro (#1A1D2E) - Para fondos principales
  static const Color backgroundDark = Color(0xFF1A1D2E);
  
  /// Blanco (#FFFFFF) - Para tarjetas y modales
  static const Color backgroundLight = Color(0xFFFFFFFF);
  
  /// Gris claro (#F5F5F5) - Para superficies secundarias
  static const Color surface = Color(0xFFF5F5F5);
  
  // ========== COLORES DE TEXTO ==========
  
  /// Blanco (#FFFFFF) - Para texto en fondos oscuros
  static const Color textPrimary = Color(0xFFFFFFFF);
  
  /// Gris (#8A8A8A) - Para texto de soporte
  static const Color textSecondary = Color(0xFF8A8A8A);
  
  /// Negro (#000000) - Para texto en superficies claras
  static const Color textDark = Color(0xFF000000);
  
  // ========== COLORES DE ESTADO ==========
  
  /// Verde (#00A86B) - Para operaciones exitosas y checkmarks
  static const Color success = Color(0xFF00A86B);
  
  /// Rojo - Para errores
  static const Color error = Color(0xFFEF4444);
  
  /// Naranja/Amarillo - Para advertencias y badges
  static const Color warning = Color(0xFFFFA500);
  
  /// Azul - Para información
  static const Color info = Color(0xFF3B82F6);
  
  // ========== COLORES ADICIONALES ==========
  
  /// Gris para bordes y separadores
  static const Color border = Color(0xFFE5E5E5);
  
  /// Gris para sombras sutiles
  static const Color shadow = Color(0x1A000000);
  
  /// Gris para overlays y modales
  static const Color overlay = Color(0x80000000);
  
  // ========== COLORES DE COMPATIBILIDAD (Deprecated) ==========
  
  /// Verde oscuro (mantener compatibilidad)
  @Deprecated('Usar AppColors.primary en su lugar')
  static const Color greenDark = Color(0xFF086046);
  
  /// Verde medio (mantener compatibilidad)
  @Deprecated('Usar AppColors.primary en su lugar')
  static const Color green = Color(0xFF14845F);
  
  /// Amarillo (mantener compatibilidad)
  @Deprecated('Usar AppColors.secondary en su lugar')
  static const Color yellow = Color(0xFFFAB238);
  
  /// Blanco (mantener compatibilidad)
  static const Color white = Color(0xFFFFFFFF);
  
  /// Gris oscuro (mantener compatibilidad)
  @Deprecated('Usar AppColors.textSecondary en su lugar')
  static const Color greyDark = Color(0xFF484848);
  
  // Constructor privado para evitar instanciación
  AppColors._();
}

