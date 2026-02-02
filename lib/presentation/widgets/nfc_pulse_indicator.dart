import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// NFC Pulse Indicator States
enum NfcPulseState {
  idle,
  listening,
  detected,
  success,
  error,
}

/// NFC Pulse Indicator Widget
/// Animated pulse effect for NFC listening state
class NfcPulseIndicator extends StatefulWidget {
  final NfcPulseState state;
  final double size;

  const NfcPulseIndicator({
    Key? key,
    this.state = NfcPulseState.listening,
    this.size = 200,
  }) : super(key: key);

  @override
  State<NfcPulseIndicator> createState() => _NfcPulseIndicatorState();
}

class _NfcPulseIndicatorState extends State<NfcPulseIndicator>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rippleController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the center circle
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // Ripple animation for expanding circles
    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _startAnimations();
  }

  @override
  void didUpdateWidget(NfcPulseIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _handleStateChange();
    }
  }

  void _startAnimations() {
    if (widget.state == NfcPulseState.listening ||
        widget.state == NfcPulseState.idle) {
      _pulseController.repeat(reverse: true);
      _rippleController.repeat();
    }
  }

  void _stopAnimations() {
    _pulseController.stop();
    _rippleController.stop();
  }

  void _handleStateChange() {
    switch (widget.state) {
      case NfcPulseState.idle:
      case NfcPulseState.listening:
        _startAnimations();
        break;
      case NfcPulseState.detected:
      case NfcPulseState.success:
      case NfcPulseState.error:
        _stopAnimations();
        _pulseController.animateTo(1.0);
        break;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Color get _stateColor {
    switch (widget.state) {
      case NfcPulseState.idle:
        return AppColors.grey400;
      case NfcPulseState.listening:
        return AppColors.primaryBlue;
      case NfcPulseState.detected:
        return AppColors.warning;
      case NfcPulseState.success:
        return AppColors.success;
      case NfcPulseState.error:
        return AppColors.error;
    }
  }

  IconData get _stateIcon {
    switch (widget.state) {
      case NfcPulseState.idle:
      case NfcPulseState.listening:
        return Icons.nfc_rounded;
      case NfcPulseState.detected:
        return Icons.sensors_rounded;
      case NfcPulseState.success:
        return Icons.check_circle_rounded;
      case NfcPulseState.error:
        return Icons.error_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Ripple Circles (only when listening/idle)
          if (widget.state == NfcPulseState.listening ||
              widget.state == NfcPulseState.idle)
            ..._buildRipples(),

          // Pulsing Center Circle
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: widget.size * 0.5,
              height: widget.size * 0.5,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    _stateColor,
                    _stateColor.withOpacity(0.6),
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _stateColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: Icon(
                _stateIcon,
                size: widget.size * 0.25,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildRipples() {
    return List.generate(3, (index) {
      return AnimatedBuilder(
        animation: _rippleController,
        builder: (context, child) {
          final delay = index * 0.33;
          final progress = (_rippleController.value + delay) % 1.0;

          return Opacity(
            opacity: 1.0 - progress,
            child: Container(
              width: widget.size * progress,
              height: widget.size * progress,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _stateColor.withOpacity(0.5),
                  width: 2,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
