import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Tarjeta de resumen de transacción
class TransactionSummaryCard extends StatelessWidget {
  final String chargesLabel;
  final String chargesValue;
  final String receiveLabel;
  final String receiveValue;

  const TransactionSummaryCard({
    super.key,
    required this.chargesLabel,
    required this.chargesValue,
    required this.receiveLabel,
    required this.receiveValue,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF252940) : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            _buildSummaryRow(chargesLabel, chargesValue, isDark),
            const SizedBox(height: 16),
            Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(receiveLabel, receiveValue, isDark, isHighlight: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w400,
            color: isHighlight
                ? AppColors.primary
                : (isDark ? AppColors.textPrimary : AppColors.textDark),
          ),
        ),
      ],
    );
  }
}

