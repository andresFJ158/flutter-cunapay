import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Skeleton loader para la pantalla del dashboard/home
class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: false,
          pinned: true,
          backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
          elevation: 0,
          leading: _buildSkeletonBox(40, 40, isDark, isCircle: true),
          title: _buildSkeletonBox(100, 20, isDark),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),
                // Balance Card Skeleton
                _buildSkeletonBox(double.infinity, 180, isDark, borderRadius: 24),
                const SizedBox(height: AppSpacing.lg),
                // Action Buttons Skeleton
                Row(
                  children: [
                    Expanded(child: _buildActionButtonSkeleton(isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildActionButtonSkeleton(isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildActionButtonSkeleton(isDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),
                // Transacciones Title Skeleton
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSkeletonBox(120, 24, isDark),
                    _buildSkeletonBox(80, 20, isDark),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                // Transaction Items Skeleton
                ...List.generate(3, (index) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.sm),
                      child: _buildTransactionSkeleton(isDark),
                    )),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSkeletonBox(double width, double height, bool isDark, {double borderRadius = 16, bool isCircle = false}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: isCircle
            ? BorderRadius.circular(height / 2)
            : BorderRadius.circular(borderRadius),
      ),
    );
  }

  Widget _buildActionButtonSkeleton(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          _buildSkeletonBox(48, 48, isDark, isCircle: true),
          const SizedBox(height: 8),
          _buildSkeletonBox(60, 12, isDark),
        ],
      ),
    );
  }

  Widget _buildTransactionSkeleton(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          _buildSkeletonBox(44, 44, isDark, borderRadius: 12),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonBox(100, 14, isDark),
                const SizedBox(height: 8),
                _buildSkeletonBox(80, 12, isDark),
              ],
            ),
          ),
          _buildSkeletonBox(100, 16, isDark),
        ],
      ),
    );
  }
}

