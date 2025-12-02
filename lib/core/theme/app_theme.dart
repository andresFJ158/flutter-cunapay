import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_fonts.dart';

/// Sistema de diseño profesional para CunaPay
/// 
/// Modern Financial App UI - Clean, card-based interface
/// con énfasis en jerarquía y legibilidad
class AppTheme {
  // ========== COLORES DEL SISTEMA ==========
  
  /// Color primario - Verde esmeralda (#00A86B)
  static const Color primaryColor = AppColors.primary;
  
  /// Color secundario - Amarillo lima (#C8E86A)
  static const Color secondaryColor = AppColors.secondary;
  
  /// Color de éxito
  static const Color successColor = AppColors.success;
  
  /// Color de error
  static const Color errorColor = AppColors.error;
  
  /// Color de advertencia
  static const Color warningColor = AppColors.warning;
  
  /// Color de información
  static const Color infoColor = AppColors.info;
  
  /// Color de superficie - Para fondos de pantalla
  static const Color surfaceColor = AppColors.surface;
  
  /// Color de acento - Color secundario para elementos destacados
  static const Color accentColor = AppColors.secondary;
  
  // ========== TEMA CLARO ==========
  
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: AppFonts.fontFamily,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: successColor,
        surface: AppColors.backgroundLight,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textDark,
        onSurfaceVariant: AppColors.textSecondary,
        error: errorColor,
        onError: AppColors.textPrimary,
      ),
      
      // Fondo del scaffold
      scaffoldBackgroundColor: AppColors.surface,
      
      // ========== TIPOGRAFÍA ==========
      // Todos usan Garet-Book (FontWeight.w400) para consistencia
      textTheme: TextTheme(
        // Header - 24-28px, Garet-Book
        displayLarge: AppFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        // Title - 20-24px, Garet-Book
        displayMedium: AppFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        displaySmall: AppFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        // Balance - 32-36px, Garet-Book
        headlineLarge: AppFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: AppFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        // Body - 14-16px, Garet-Book
        bodyLarge: AppFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        // Caption - 12-13px, Garet-Book
        bodySmall: AppFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
          height: 1.4,
        ),
        // Label - 11-12px, Garet-Book
        labelLarge: AppFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: 0.5,
        ),
        labelMedium: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          letterSpacing: 0.5,
        ),
        labelSmall: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
        // Title variants - Garet-Book
        titleLarge: AppFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          height: 1.3,
        ),
        titleMedium: AppFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          height: 1.3,
        ),
        titleSmall: AppFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
          height: 1.4,
        ),
      ),
      
      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: AppFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textDark,
          size: 24,
        ),
      ),
      
      // ========== TARJETAS ==========
      cardTheme: CardThemeData(
        elevation: 0,
        color: AppColors.backgroundLight,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // ========== BOTONES ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
          textStyle: AppFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botón secundario
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
          textStyle: AppFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botón outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
          textStyle: AppFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botón de texto (ghost)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // ========== INPUTS ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundLight,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        hintStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
      ),
      
      // ========== ICONOS ==========
      iconTheme: const IconThemeData(
        color: AppColors.textDark,
        size: 24,
      ),
      
      // ========== DIVIDERS ==========
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      
      // ========== DIALOGS ==========
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.backgroundLight,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
        ),
        contentTextStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textDark,
        ),
      ),
      
      // ========== BOTTOM NAVIGATION ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // ========== CHIP ==========
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surface,
        selectedColor: primaryColor,
        labelStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
  
  // ========== TEMA OSCURO ==========
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: AppFonts.fontFamily,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: successColor,
        surface: AppColors.backgroundDark,
        onPrimary: AppColors.textPrimary,
        onSecondary: AppColors.textDark,
        onSurface: AppColors.textPrimary,
        onSurfaceVariant: AppColors.textSecondary,
        error: errorColor,
        onError: AppColors.textPrimary,
      ),
      
      // Fondo del scaffold
      scaffoldBackgroundColor: AppColors.backgroundDark,
      
      // ========== TIPOGRAFÍA ==========
      // Todos usan Garet-Book (FontWeight.w400) para consistencia
      textTheme: TextTheme(
        // Header - 24-28px, Garet-Book
        displayLarge: AppFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        // Title - 20-24px, Garet-Book
        displayMedium: AppFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        displaySmall: AppFonts.poppins(
          fontSize: 22,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: -0.2,
          height: 1.3,
        ),
        // Balance - 32-36px, Garet-Book
        headlineLarge: AppFonts.poppins(
          fontSize: 36,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        headlineMedium: AppFonts.poppins(
          fontSize: 32,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: -0.5,
          height: 1.2,
        ),
        // Body - 14-16px, Garet-Book
        bodyLarge: AppFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.15,
          height: 1.5,
        ),
        bodyMedium: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.25,
          height: 1.5,
        ),
        // Caption - 12-13px, Garet-Book
        bodySmall: AppFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.4,
          height: 1.4,
        ),
        // Label - 11-12px, Garet-Book
        labelLarge: AppFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          letterSpacing: 0.5,
        ),
        labelSmall: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
          letterSpacing: 0.5,
        ),
        // Title variants - Garet-Book
        titleLarge: AppFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        titleMedium: AppFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.3,
        ),
        titleSmall: AppFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
      
      // ========== APP BAR ==========
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textPrimary,
        centerTitle: false,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        titleTextStyle: AppFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(
          color: AppColors.textPrimary,
          size: 24,
        ),
      ),
      
      // ========== TARJETAS ==========
      cardTheme: CardThemeData(
        elevation: 0,
        color: const Color(0xFF252940), // Tarjeta oscura ligeramente más clara que el fondo
        shadowColor: Colors.black.withValues(alpha: 0.3),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // ========== BOTONES ==========
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
          textStyle: AppFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botón secundario
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: secondaryColor,
          foregroundColor: AppColors.textDark,
          elevation: 0,
          shadowColor: Colors.transparent,
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
          textStyle: AppFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botón outlined
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: const BorderSide(color: primaryColor, width: 1.5),
          padding: AppSpacing.buttonPadding,
          minimumSize: const Size(0, AppSpacing.buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28), // Pill shape
          ),
          textStyle: AppFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Botón de texto (ghost)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // ========== INPUTS ==========
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF252940),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2), width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.textSecondary.withValues(alpha: 0.2), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorColor, width: 2),
        ),
        labelStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary,
        ),
        hintStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textSecondary.withValues(alpha: 0.7),
        ),
      ),
      
      // ========== ICONOS ==========
      iconTheme: const IconThemeData(
        color: AppColors.textPrimary,
        size: 24,
      ),
      
      // ========== DIVIDERS ==========
      dividerTheme: DividerThemeData(
        color: AppColors.textSecondary.withValues(alpha: 0.2),
        thickness: 1,
        space: 1,
      ),
      
      // ========== DIALOGS ==========
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF252940),
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: AppFonts.poppins(
          fontSize: 24,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: AppColors.textPrimary,
        ),
      ),
      
      // ========== BOTTOM NAVIGATION ==========
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDark,
        selectedItemColor: primaryColor,
        unselectedItemColor: AppColors.textSecondary,
        selectedLabelStyle: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        unselectedLabelStyle: AppFonts.poppins(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // ========== FLOATING ACTION BUTTON ==========
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: AppColors.textPrimary,
        elevation: 4,
        shape: CircleBorder(),
      ),
      
      // ========== CHIP ==========
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF252940),
        selectedColor: primaryColor,
        labelStyle: AppFonts.poppins(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
