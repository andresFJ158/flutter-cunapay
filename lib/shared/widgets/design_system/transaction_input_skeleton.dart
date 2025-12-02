import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

/// Skeleton loader para pantalla de entrada de transacción
class TransactionInputSkeleton extends StatelessWidget {
  const TransactionInputSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            // Header skeleton
            Container(
              height: 64,
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Row(
                children: [
                  _buildSkeletonBox(44, 44, isDark),
                  const Spacer(),
                  _buildSkeletonBox(44, 44, isDark),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Balance skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: _buildSkeletonBox(double.infinity, 80, isDark),
            ),
            const Spacer(),
            // Amount display skeleton
            _buildSkeletonBox(200, 80, isDark),
            const Spacer(),
            // Numpad skeleton
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.screenHorizontal),
              child: Column(
                children: List.generate(4, (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(3, (_) => _buildSkeletonBox(100, 64, isDark)),
                  ),
                )),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height, bool isDark) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}

