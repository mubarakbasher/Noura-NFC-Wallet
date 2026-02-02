import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import 'animated_balance.dart';

/// Enhanced Balance Card Widget - RedotPay-inspired
/// Large animated balance display with gradient background
class BalanceCardWidget extends StatelessWidget {
  final double balance;
  final String currency;
  final String userName;
  final bool isActive;
  final VoidCallback? onTap;

  const BalanceCardWidget({
    Key? key,
    required this.balance,
    this.currency = 'ج.س',
    this.userName = 'Demo User',
    this.isActive = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(AppTheme.space16),
        padding: const EdgeInsets.all(AppTheme.space24),
        decoration: BoxDecoration(
          gradient: AppColors.balanceGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          boxShadow: AppTheme.primaryGradientShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Available Balance',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                // Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.space12,
                    vertical: AppTheme.space4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                    border: Border.all(
                      color: AppColors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.success : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: AppTheme.space4),
                      Text(
                        isActive ? 'ACTIVE' : 'INACTIVE',
                        style: AppTextStyles.chip.copyWith(
                          color: AppColors.white,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space16),

            // Animated Balance Display
            AnimatedBalanceWidget(
              balance: balance,
              currency: currency,
              duration: const Duration(milliseconds: 1500),
            ),

            const SizedBox(height: AppTheme.space20),

            // User Info Row
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.space8),
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    color: AppColors.white.withOpacity(0.9),
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userName,
                      style: AppTextStyles.titleSmall.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Primary Wallet',
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.white.withOpacity(0.7),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: AppTheme.space16),

            // Balance Stats Row (Optional)
            Divider(
              color: AppColors.white.withOpacity(0.2),
              thickness: 1,
              height: 1,
            ),
            
            const SizedBox(height: AppTheme.space16),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.arrow_upward_rounded,
                  label: 'Sent',
                  value: currency + '0.00',
                ),
                Container(
                  width: 1,
                  height: 30,
                  color: AppColors.white.withOpacity(0.2),
                ),
                _buildStatItem(
                  icon: Icons.arrow_downward_rounded,
                  label: 'Received',
                  value: currency + '0.00',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppColors.white.withOpacity(0.8),
              size: 16,
            ),
            const SizedBox(width: AppTheme.space4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.space4),
        Text(
          value,
          style: AppTextStyles.titleSmall.copyWith(
            color: AppColors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
