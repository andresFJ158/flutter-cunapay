import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Skeleton loader para la pantalla de staking
class StakingSkeleton extends StatelessWidget {
  const StakingSkeleton({super.key});

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
          automaticallyImplyLeading: false,
          title: _buildSkeletonBox(100, 20, isDark),
          centerTitle: true,
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.screenHorizontal),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjetas de saldo skeleton
                Row(
                  children: [
                    Expanded(child: _buildBalanceCardSkeleton(isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildBalanceCardSkeleton(isDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Botón crear stake skeleton
                _buildSkeletonBox(double.infinity, 54, isDark, borderRadius: 27),
                const SizedBox(height: AppSpacing.xl),
                // Filtros skeleton
                Row(
                  children: [
                    Expanded(child: _buildFilterChipSkeleton(isDark)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: _buildFilterChipSkeleton(isDark)),
                  ],
                ),
                const SizedBox(height: AppSpacing.lg),
                // Stakes skeleton
                ...List.generate(3, (index) => Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.md),
                      child: _buildStakeCardSkeleton(isDark),
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

  Widget _buildBalanceCardSkeleton(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSkeletonBox(60, 12, isDark),
          const SizedBox(height: 8),
          _buildSkeletonBox(80, 24, isDark),
        ],
      ),
    );
  }

  Widget _buildFilterChipSkeleton(bool isDark) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
          width: 1,
        ),
      ),
    );
  }

  Widget _buildStakeCardSkeleton(bool isDark) {
    return Container(
      padding: EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF252940) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: (isDark ? AppColors.textPrimary : AppColors.textDark).withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSkeletonBox(120, 22, isDark),
                  const SizedBox(height: 4),
                  _buildSkeletonBox(100, 14, isDark),
                ],
              ),
              _buildSkeletonBox(80, 36, isDark, borderRadius: 12),
            ],
          ),
          const SizedBox(height: 12),
          _buildSkeletonBox(double.infinity, 60, isDark, borderRadius: 12),
        ],
      ),
    );
  }
}
