import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Header moderno para pantallas de transacciones
/// 
/// Incluye botón de retroceso, título centrado y botón de menú
class TransactionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onMenu;
  final Color? backgroundColor;

  const TransactionHeader({
    super.key,
    required this.title,
    this.onBack,
    this.onMenu,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = backgroundColor ?? 
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);

    return Container(
      height: 64, // 56-64px según especificación
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      color: bgColor,
      child: Row(
        children: [
          // Botón de retroceso
          _HeaderButton(
            icon: Icons.chevron_left_rounded,
            onTap: onBack ?? () => Navigator.of(context).pop(),
            size: 44, // 40-44px según especificación
          ),
          
          // Título centrado
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 19, // 18-20px según especificación
                fontWeight: FontWeight.w400, // 600-700 según especificación
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ),
          
          // Botón de información
          _HeaderButton(
            icon: Icons.info_outline_rounded,
            onTap: onMenu,
            size: 44, // 40-44px según especificación
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final double size;

  const _HeaderButton({
    required this.icon,
    this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: isDark 
                ? const Color(0xFF252940) 
                : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            size: 22,
            color: isDark ? AppColors.textPrimary : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}

