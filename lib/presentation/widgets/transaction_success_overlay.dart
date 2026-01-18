import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Transaction Success Overlay
/// Full-screen animated success feedback with confetti
class TransactionSuccessOverlay extends StatefulWidget {
  final double amount;
  final bool isCredit;
  final VoidCallback onComplete;

  const TransactionSuccessOverlay({
    Key? key,
    required this.amount,
    required this.isCredit,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<TransactionSuccessOverlay> createState() =>
      _TransactionSuccessOverlayState();

  static void show(
    BuildContext context, {
    required double amount,
    required bool isCredit,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) => TransactionSuccessOverlay(
        amount: amount,
        isCredit: isCredit,
        onComplete: () => Navigator.of(context).pop(),
      ),
    );
  }
}

class _TransactionSuccessOverlayState extends State<TransactionSuccessOverlay>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _confettiController;
  late AnimationController _fadeController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Scale animation for check icon
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    // Confetti animation
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Fade out animation
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    // Start animations
    _scaleController.forward();
    _confettiController.forward();

    // Auto dismiss after 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      _fadeController.forward().then((_) {
        widget.onComplete();
      });
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _confettiController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isCredit ? Colors.green : Colors.blue;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Confetti particles
            ...List.generate(30, (index) {
              return _ConfettiParticle(
                animation: _confettiController,
                index: index,
              );
            }),

            // Success content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated check icon
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: color.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Success text
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0.0, end: 1.0),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Text(
                          widget.isCredit
                              ? 'Payment Received!'
                              : 'Payment Sent!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '${widget.isCredit ? '+' : '-'}\$${widget.amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: color,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfettiParticle extends StatelessWidget {
  final Animation<double> animation;
  final int index;

  const _ConfettiParticle({
    required this.animation,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final random = math.Random(index);
    final startX = random.nextDouble();
    final endX = startX + (random.nextDouble() - 0.5) * 0.3;
    final rotation = random.nextDouble() * math.pi * 4;
    final color = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
    ][random.nextInt(6)];

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final screenHeight = MediaQuery.of(context).size.height;
        final screenWidth = MediaQuery.of(context).size.width;

        return Positioned(
          left: screenWidth * (startX + (endX - startX) * animation.value),
          top: -20 + screenHeight * animation.value,
          child: Transform.rotate(
            angle: rotation * animation.value,
            child: Opacity(
              opacity: 1.0 - animation.value,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
