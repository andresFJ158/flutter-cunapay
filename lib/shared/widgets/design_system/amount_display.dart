import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Display grande de cantidad para transacciones
class AmountDisplay extends StatelessWidget {
  final String currencySymbol;
  final String amount;

  const AmountDisplay({
    super.key,
    required this.currencySymbol,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            currencySymbol,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w300,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount.isEmpty ? '0.00' : amount,
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w300,
              color: isDark ? AppColors.textPrimary : AppColors.textDark,
              letterSpacing: -2,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

