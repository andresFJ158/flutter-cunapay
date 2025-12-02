import 'package:flutter/material.dart';

/// Helper para usar la fuente Garet local
/// Esto evita el delay de carga desde la red
class AppFonts {
  static const String fontFamily = 'Garet';
  
  /// Crea un TextStyle con la fuente Garet local
  /// Siempre usa FontWeight.w400 (Garet-Book) - sin negrita
  static TextStyle garet({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: FontWeight.w400, // Siempre Garet-Book, sin negrita
      color: color,
      letterSpacing: letterSpacing,
      height: height,
      decoration: decoration,
      decorationColor: decorationColor,
    );
  }
  
  /// Alias para mantener compatibilidad (usa garet internamente)
  /// Siempre usa FontWeight.w400 (Garet-Book) - sin negrita
  static TextStyle poppins({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? letterSpacing,
    double? height,
    TextDecoration? decoration,
    Color? decorationColor,
  }) => garet(
    fontSize: fontSize,
    fontWeight: FontWeight.w400, // Siempre Garet-Book, sin negrita
    color: color,
    letterSpacing: letterSpacing,
    height: height,
    decoration: decoration,
    decorationColor: decorationColor,
  );
}

