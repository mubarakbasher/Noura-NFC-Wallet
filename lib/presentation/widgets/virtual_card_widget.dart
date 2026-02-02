import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Virtual Card Widget - RedotPay-style card preview
/// Displays masked card number, expiry, and card brand
class VirtualCardWidget extends StatefulWidget {
  final String? cardNumber;
  final String? expiryDate;
  final String? cardHolderName;
  final bool isFrozen;
  final VoidCallback? onTap;

  const VirtualCardWidget({
    Key? key,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.isFrozen = false,
    this.onTap,
  }) : super(key: key);

  @override
  State<VirtualCardWidget> createState() => _VirtualCardWidgetState();
}

class _VirtualCardWidgetState extends State<VirtualCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  String get _maskedCardNumber {
    if (widget.cardNumber == null || widget.cardNumber!.isEmpty) {
      return '•••• •••• •••• 1234';
    }
    final last4 = widget.cardNumber!.substring(
      widget.cardNumber!.length - 4,
    );
    return '•••• •••• •••• $last4';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          height: 200,
          margin: const EdgeInsets.symmetric(
            horizontal: AppTheme.space16,
            vertical: AppTheme.space8,
          ),
          decoration: BoxDecoration(
            gradient: widget.isFrozen
                ? LinearGradient(
                    colors: [
                      AppColors.grey600,
                      AppColors.grey700,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : AppColors.cardGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: widget.isFrozen
                ? []
                : AppTheme.primaryGradientShadow,
          ),
          child: Stack(
            children: [
              // Card Chip (Top Left)
              Positioned(
                top: AppTheme.space24,
                left: AppTheme.space24,
                child: Container(
                  width: 48,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.credit_card_rounded,
                      color: AppColors.white.withOpacity(0.8),
                      size: 24,
                    ),
                  ),
                ),
              ),

              // Frozen Badge (Top Right)
              if (widget.isFrozen)
                Positioned(
                  top: AppTheme.space24,
                  right: AppTheme.space24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.space12,
                      vertical: AppTheme.space4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(AppTheme.radiusCircle),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.ac_unit,
                          color: AppColors.white,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'FROZEN',
                          style: AppTextStyles.chip.copyWith(
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Card Number (Center)
              Positioned(
                top: 100,
                left: AppTheme.space24,
                right: AppTheme.space24,
                child: Text(
                  _maskedCardNumber,
                  style: AppTextStyles.cardNumber,
                ),
              ),

              // Card Details (Bottom)
              Positioned(
                bottom: AppTheme.space24,
                left: AppTheme.space24,
                right: AppTheme.space24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Cardholder Name
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CARDHOLDER',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white.withOpacity(0.6),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.cardHolderName?.toUpperCase() ?? 'DEMO USER',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    // Expiry Date
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'EXPIRES',
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.white.withOpacity(0.6),
                            fontSize: 9,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.expiryDate ?? '12/26',
                          style: AppTextStyles.labelMedium.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // NFC Icon (Bottom Right)
              Positioned(
                bottom: AppTheme.space24,
                right: AppTheme.space24,
                child: Icon(
                  Icons.contactless_rounded,
                  color: AppColors.white.withOpacity(0.8),
                  size: 32,
                ),
              ),

              // Glassmorphism Overlay
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  border: Border.all(
                    color: AppColors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
