import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';

/// Quick Action Button Model
class QuickAction {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.id,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}

/// Quick Action Grid Widget - RedotPay-style action buttons
/// 2x2 or 2x3 grid of primary actions
class QuickActionGrid extends StatelessWidget {
  final List<QuickAction> actions;
  final int crossAxisCount;

  const QuickActionGrid({
    Key? key,
    required this.actions,
    this.crossAxisCount = 2,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: AppTheme.space12,
          mainAxisSpacing: AppTheme.space12,
          childAspectRatio: 1.0,
        ),
        itemCount: actions.length,
        itemBuilder: (context, index) {
          return QuickActionButton(action: actions[index]);
        },
      ),
    );
  }
}

/// Individual Quick Action Button
class QuickActionButton extends StatefulWidget {
  final QuickAction action;

  const QuickActionButton({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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
    widget.action.onTap();
  }

  void _onTapCancel() {
    _controller.reverse();
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
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.cardLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            boxShadow: AppTheme.cardShadow(),
            border: Border.all(
              color: isDark
                  ? AppColors.grey700
                  : AppColors.grey200.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container with Gradient Background
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      widget.action.color.withOpacity(0.2),
                      widget.action.color.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: widget.action.color.withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  widget.action.icon,
                  color: widget.action.color,
                  size: 32,
                ),
              ),

              const SizedBox(height: AppTheme.space12),

              // Label
              Text(
                widget.action.label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
