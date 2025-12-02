import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Extensiones útiles para trabajar con el sistema de diseño
extension AppThemeExtensions on BuildContext {
  /// Obtiene el tema actual
  ThemeData get theme => Theme.of(this);
  
  /// Obtiene el esquema de colores actual
  ColorScheme get colors => Theme.of(this).colorScheme;
  
  /// Verifica si está en modo oscuro
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
  
  /// Obtiene el color de texto apropiado según el tema
  Color get textColor => isDarkMode ? AppColors.textPrimary : AppColors.textDark;
  
  /// Obtiene el color de texto secundario
  Color get textSecondaryColor => AppColors.textSecondary;
  
  /// Obtiene el color de fondo apropiado según el tema
  Color get backgroundColor => isDarkMode 
      ? AppColors.backgroundDark 
      : AppColors.surface;
  
  /// Obtiene el color de superficie (tarjetas)
  Color get surfaceColor => isDarkMode 
      ? const Color(0xFF252940) 
      : AppColors.backgroundLight;
}

/// Extensiones para TextStyles del sistema de diseño
extension AppTextStyles on TextStyle {
  /// Aplica el color de texto primario según el tema
  TextStyle withPrimaryColor(BuildContext context) {
    return copyWith(color: context.textColor);
  }
  
  /// Aplica el color de texto secundario
  TextStyle withSecondaryColor() {
    return copyWith(color: AppColors.textSecondary);
  }
  
  /// Aplica el color de éxito
  TextStyle withSuccessColor() {
    return copyWith(color: AppColors.success);
  }
  
  /// Aplica el color de error
  TextStyle withErrorColor() {
    return copyWith(color: AppColors.error);
  }
}

