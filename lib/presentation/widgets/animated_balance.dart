import 'package:flutter/material.dart';

/// Animated Balance Widget
/// Shows counting animation when balance changes
class AnimatedBalanceWidget extends StatefulWidget {
  final double balance;
  final String currency;
  final Duration duration;

  const AnimatedBalanceWidget({
    Key? key,
    required this.balance,
    this.currency = '\$',
    this.duration = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  State<AnimatedBalanceWidget> createState() => _AnimatedBalanceWidgetState();
}

class _AnimatedBalanceWidgetState extends State<AnimatedBalanceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _previousBalance = 0;

  @override
  void initState() {
    super.initState();
    _previousBalance = widget.balance;
    
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _animation = Tween<double>(
      begin: _previousBalance,
      end: widget.balance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
  }

  @override
  void didUpdateWidget(AnimatedBalanceWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.balance != widget.balance) {
      _previousBalance = oldWidget.balance;
      
      _animation = Tween<double>(
        begin: _previousBalance,
        end: widget.balance,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.elasticOut,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: _controller.isAnimating ? scale : 1.0,
              child: Text(
                '${widget.currency}${_animation.value.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
