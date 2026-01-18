import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nfc/nfc_bloc.dart';
import '../../bloc/nfc/nfc_event.dart';
import '../../bloc/nfc/nfc_state.dart';

class PayScreen extends StatefulWidget {
  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  // Mock user data - replace with real data from auth
  final String userId = 'user_123';
  final String walletId = 'wallet_456';
  final String deviceId = 'device_789';

  @override
  void initState() {
    super.initState();
    
    // Pulse animation for NFC indicator
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _enablePaymentMode() {
    context.read<NfcBloc>().add(
          EnableHceMode(
            userId: userId,
            walletId: walletId,
            deviceId: deviceId,
          ),
        );
  }

  void _disablePaymentMode() {
    context.read<NfcBloc>().add(DisableHceMode());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pay with NFC'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<NfcBloc, NfcState>(
        listener: (context, state) {
          if (state is NfcFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is HceInactive) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // Virtual Card
                  _buildVirtualCard(),

                  const SizedBox(height: 40),

                  // NFC Status
                  _buildNfcStatus(state),

                  const SizedBox(height: 40),

                  // Action Button
                  _buildActionButton(state),

                  const SizedBox(height: 24),

                  // Instructions
                  _buildInstructions(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVirtualCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.nfc, color: Colors.white, size: 40),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Virtual Card',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          const Text(
            'NFC Wallet',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '**** **** **** 4567',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'CARDHOLDER',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Demo User',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: const [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '12/25',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNfcStatus(NfcState state) {
    if (state is HceActivating) {
      return Column(
        children: [
          const CircularProgressIndicator(color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Activating payment mode...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      );
    }

    if (state is HceActive) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.green,
                  width: 3,
                ),
              ),
              child: const Icon(
                Icons.nfc,
                size: 60,
                color: Colors.green,
              ),
            ),
          );
        },
      );
    }

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.grey,
          width: 3,
        ),
      ),
      child: Icon(
        Icons.nfc,
        size: 60,
        color: Colors.grey[400],
      ),
    );
  }

  Widget _buildActionButton(NfcState state) {
    if (state is HceActive) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _disablePaymentMode,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            'Cancel Payment',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state is HceActivating ? null : _enablePaymentMode,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Enable Payment Mode',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildInstructions(NfcState state) {
    String title;
    String description;
    IconData icon;
    Color color;

    if (state is HceActive) {
      title = 'Ready to Pay';
      description = 'Hold your phone near the payment terminal to complete the transaction.';
      icon = Icons.check_circle;
      color = Colors.green;
    } else if (state is HceActivating) {
      title = 'Activating...';
      description = 'Please wait while we prepare your payment.';
      icon = Icons.hourglass_empty;
      color = Colors.orange;
    } else {
      title = 'Tap to Enable';
      description = 'Tap the button above to activate NFC payment mode, then hold your phone near a payment terminal.';
      icon = Icons.info;
      color = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
