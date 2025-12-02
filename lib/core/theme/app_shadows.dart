import 'package:flutter/material.dart';

/// Sistema de sombras consistente para la aplicación
/// 
/// Define sombras para diferentes niveles de elevación
class AppShadows {
  // Sombra para tarjetas primarias (elevación media)
  static List<BoxShadow> get cardPrimary => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 12.0,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  // Sombra para tarjetas secundarias (elevación ligera)
  static List<BoxShadow> get cardSecondary => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8.0,
      offset: const Offset(0, 2),
      spreadRadius: 0,
    ),
  ];
  
  // Sombra para botones
  static List<BoxShadow> get button => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 8.0,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];
  
  // Sombra para barra de navegación inferior
  static List<BoxShadow> get bottomNav => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.1),
      blurRadius: 12.0,
      offset: const Offset(0, -4),
      spreadRadius: 0,
    ),
  ];
  
  // Sombra para modales y diálogos
  static List<BoxShadow> get modal => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 24.0,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  // Constructor privado
  AppShadows._();
}

