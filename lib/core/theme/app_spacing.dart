import 'package:flutter/material.dart';

/// Sistema de espaciado consistente para la aplicación
/// 
/// Basado en una escala de 4px para mantener coherencia visual
class AppSpacing {
  // Espaciado base
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  
  // Márgenes de pantalla
  static const double screenHorizontal = 16.0;
  static const double screenVertical = 24.0;
  
  // Espaciado entre secciones
  static const double sectionSpacing = 24.0;
  
  // Gaps para grids
  static const double gridGap = 12.0;
  
  // Padding de tarjetas
  static const double cardPaddingPrimary = 20.0;
  static const double cardPaddingSecondary = 16.0;
  static const double cardPaddingReceipt = 24.0;
  
  // Padding de botones
  static const double buttonPaddingHorizontal = 14.0;
  static const double buttonPaddingVertical = 16.0;
  
  // Altura de elementos
  static const double buttonHeight = 56.0;
  static const double listItemHeight = 72.0;
  static const double headerHeight = 56.0;
  static const double bottomNavHeight = 64.0;
  
  // Tamaños de iconos
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 28.0;
  static const double iconButtonSize = 48.0;
  static const double iconButtonContainerSize = 64.0;
  
  // Constructor privado
  AppSpacing._();
  
  // Helpers para EdgeInsets
  static EdgeInsets get screenPadding => const EdgeInsets.symmetric(
    horizontal: screenHorizontal,
    vertical: screenVertical,
  );
  
  static EdgeInsets get cardPaddingPrimaryEdgeInsets => const EdgeInsets.all(cardPaddingPrimary);
  static EdgeInsets get cardPaddingSecondaryEdgeInsets => const EdgeInsets.all(cardPaddingSecondary);
  static EdgeInsets get cardPaddingReceiptEdgeInsets => const EdgeInsets.all(cardPaddingReceipt);
  
  static EdgeInsets get buttonPadding => const EdgeInsets.symmetric(
    horizontal: buttonPaddingHorizontal,
    vertical: buttonPaddingVertical,
  );
}

