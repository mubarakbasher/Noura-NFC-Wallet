import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Shimmer Loading Widgets
/// Professional skeleton loaders for various components

/// Balance Card Shimmer
class BalanceCardShimmer extends StatelessWidget {
  const BalanceCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.all(AppTheme.space16),
      padding: const EdgeInsets.all(AppTheme.space24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        highlightColor: isDark
            ? AppColors.shimmerHighlightDark
            : AppColors.shimmerHighlight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 120,
                  height: 14,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                ),
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space16),

            // Balance Amount
            Container(
              width: 200,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),

            const SizedBox(height: AppTheme.space20),

            // User Info
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: AppColors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusSmall),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Transaction Item Shimmer
class TransactionItemShimmer extends StatelessWidget {
  const TransactionItemShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        highlightColor: isDark
            ? AppColors.shimmerHighlightDark
            : AppColors.shimmerHighlight,
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(width: AppTheme.space12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 14,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 100,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: AppTheme.space12),

            // Amount
            Container(
              width: 80,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Action Button Shimmer
class ActionButtonShimmer extends StatelessWidget {
  const ActionButtonShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.cardShadow(),
      ),
      child: Shimmer.fromColors(
        baseColor: isDark ? AppColors.shimmerBaseDark : AppColors.shimmerBase,
        highlightColor: isDark
            ? AppColors.shimmerHighlightDark
            : AppColors.shimmerHighlight,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Circle
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
              ),
            ),

            const SizedBox(height: AppTheme.space12),

            // Label
            Container(
              width: 80,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic List Shimmer
class ListShimmer extends StatelessWidget {
  final int itemCount;

  const ListShimmer({
    Key? key,
    this.itemCount = 5,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: itemCount,
      itemBuilder: (context, index) => const TransactionItemShimmer(),
    );
  }
}
