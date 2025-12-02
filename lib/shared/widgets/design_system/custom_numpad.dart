import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Numpad personalizado moderno
class CustomNumpad extends StatelessWidget {
  final Function(String) onNumberTap;
  final VoidCallback onDelete;
  final VoidCallback onDeleteLongPress;
  final bool showDecimal;

  const CustomNumpad({
    super.key,
    required this.onNumberTap,
    required this.onDelete,
    required this.onDeleteLongPress,
    this.showDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Column(
        children: [
          _buildRow(['1', '2', '3'], isDark),
          const SizedBox(height: 8),
          _buildRow(['4', '5', '6'], isDark),
          const SizedBox(height: 8),
          _buildRow(['7', '8', '9'], isDark),
          const SizedBox(height: 8),
          _buildRow(
            showDecimal ? ['.', '0', ''] : ['', '0', ''],
            isDark,
            showDelete: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> numbers, bool isDark, {bool showDelete = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: numbers.asMap().entries.map((entry) {
        final index = entry.key;
        final number = entry.value;

        if (number.isEmpty) {
          return Expanded(
            child: _buildDeleteButton(isDark, showDelete),
          );
        }

        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: index == 1 ? 8 : 0),
            child: _buildNumberButton(number, isDark),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNumberButton(String number, bool isDark) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onNumberTap(number),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252940) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Text(
              number,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.textPrimary : AppColors.textDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(bool isDark, bool showDelete) {
    if (!showDelete) {
      return const SizedBox.shrink();
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onDelete,
        onLongPress: onDeleteLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF252940) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.backspace_outlined,
            color: isDark ? AppColors.textPrimary : AppColors.textDark,
            size: 20,
          ),
        ),
      ),
    );
  }
}

