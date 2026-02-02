import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nfc/nfc_bloc.dart';
import '../../bloc/nfc/nfc_event.dart';
import '../../bloc/nfc/nfc_state.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../../domain/entities/wallet.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../widgets/nfc_pulse_indicator.dart';
import '../../widgets/transaction_success_overlay.dart';

/// Pay Screen - User enters amount and enables NFC payment mode
class PayScreen extends StatefulWidget {
  const PayScreen({Key? key}) : super(key: key);

  @override
  State<PayScreen> createState() => _PayScreenState();
}

class _PayScreenState extends State<PayScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  double _paymentAmount = 0.0;
  bool _isPaymentActive = false;
  bool _paymentConfirmed = false;

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
    _amountController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _startPayment() {
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid amount'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          ),
        ),
      );
      return;
    }

    // Get wallet state to check balance
    final walletState = context.read<WalletBloc>().state;
    if (walletState is WalletLoaded) {
      if (walletState.balance < amount) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Insufficient balance'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
          ),
        );
        return;
      }

      setState(() {
        _paymentAmount = amount;
        _isPaymentActive = true;
        _paymentConfirmed = false;
      });

      // Enable HCE mode with amount
      context.read<NfcBloc>().add(
        EnableHceMode(
          userId: walletState.userId,
          walletId: walletState.id,
          deviceId: 'device_${walletState.userId}',
          amount: amount,
        ),
      );
      HapticFeedback.mediumImpact();
    }
  }

  void _cancelPayment() {
    setState(() {
      _isPaymentActive = false;
      _paymentConfirmed = false;
    });
    context.read<NfcBloc>().add(DisableHceMode());
  }

  void _confirmPaymentSent() {
    debugPrint('💸 Payment confirmed by user: $_paymentAmount');
    HapticFeedback.heavyImpact();
    
    setState(() {
      _paymentConfirmed = true;
    });
    
    // Deduct from wallet balance (debit)
    context.read<WalletBloc>().add(NfcTransactionCompleted(
      amount: _paymentAmount,
      isCredit: false, // Sending money (debit)
      merchantName: 'NFC Payment Sent',
    ));
    
    // Disable HCE
    context.read<NfcBloc>().add(DisableHceMode());
    
    // Show success overlay
    TransactionSuccessOverlay.show(
      context,
      amount: _paymentAmount,
      isCredit: false,
    );
    
    // Go back after overlay dismisses
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Pay with NFC',
          style: AppTextStyles.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            if (_isPaymentActive) {
              _cancelPayment();
            }
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocConsumer<NfcBloc, NfcState>(
        listener: (context, state) {
          if (state is NfcFailureState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
            setState(() {
              _isPaymentActive = false;
            });
          }
        },
        builder: (context, state) {
          if (_isPaymentActive && !_paymentConfirmed) {
            return _buildPaymentActiveView(state, isDark);
          }
          return _buildAmountInputView(isDark);
        },
      ),
    );
  }

  Widget _buildAmountInputView(bool isDark) {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        double balance = 0.0;
        String currency = 'SDG';
        
        if (walletState is WalletLoaded) {
          balance = walletState.balance;
          currency = walletState.currency;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.space32),

              // Title
              Text(
                'Enter Payment Amount',
                style: AppTextStyles.headlineLarge.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: AppTheme.space12),

              // Balance Display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space16,
                  vertical: AppTheme.space8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_rounded,
                      color: AppColors.success,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.space8),
                    Text(
                      'Available Balance: ${Formatters.formatCurrency(balance, symbol: currency)}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.space48),

              // Amount Input
              Container(
                padding: const EdgeInsets.all(AppTheme.space24),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: AppTheme.elevatedShadow(color: AppColors.success),
                  border: Border.all(
                    color: AppColors.success.withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.displayLarge.copyWith(
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                    fontSize: 56,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: AppTextStyles.displayLarge.copyWith(
                      color: isDark
                          ? AppColors.textTertiaryDark
                          : AppColors.textTertiaryLight,
                      fontSize: 56,
                    ),
                    border: InputBorder.none,
                    prefixIcon: Padding(
                      padding: const EdgeInsets.only(left: 16, top: 16),
                      child: Text(
                        currency,
                        style: AppTextStyles.displayLarge.copyWith(
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondaryLight,
                          fontSize: 32,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: AppTheme.space48),

              // Continue Button
              ElevatedButton(
                onPressed: _startPayment,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  backgroundColor: AppColors.success,
                  foregroundColor: AppColors.white,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.nfc_rounded, size: 28),
                    const SizedBox(width: AppTheme.space12),
                    Text(
                      'Continue to Pay',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.space16),

              // Info Card
              Container(
                padding: const EdgeInsets.all(AppTheme.space16),
                decoration: BoxDecoration(
                  color: AppColors.infoLight.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: AppColors.info,
                      size: 24,
                    ),
                    const SizedBox(width: AppTheme.space12),
                    Expanded(
                      child: Text(
                        'Enter the amount you want to pay and hold your phone near the merchant\'s device',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.info,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPaymentActiveView(NfcState state, bool isDark) {
    NfcPulseState pulseState = NfcPulseState.listening;

    if (state is HceActive) {
      pulseState = NfcPulseState.listening;
    } else if (state is NfcFailureState) {
      pulseState = NfcPulseState.error;
    } else if (state is HceActivating) {
      pulseState = NfcPulseState.listening;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Amount Banner
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.space24,
              vertical: AppTheme.space16,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.7)],
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              boxShadow: AppTheme.elevatedShadow(color: AppColors.success),
            ),
            child: Column(
              children: [
                Text(
                  'Paying',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.space4),
                Text(
                  Formatters.formatCurrency(_paymentAmount),
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space48),

          // NFC Pulse Indicator
          NfcPulseIndicator(
            state: pulseState,
            size: 220,
          ),

          const SizedBox(height: AppTheme.space32),

          // Status Text
          Text(
            state is HceActivating
                ? 'Activating Payment...'
                : state is HceActive
                    ? 'Ready to Pay'
                    : 'Payment Mode Active',
            style: AppTextStyles.headlineMedium.copyWith(
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.space12),

          Text(
            'Hold your phone near the merchant\'s device',
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.space32),

          // Instructions
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: AppColors.warning.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppColors.warning.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.touch_app_rounded, color: AppColors.warning),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Text(
                    'After tapping, press "Confirm Payment" below',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Confirm Payment Button (Green)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _confirmPaymentSent,
              icon: const Icon(Icons.check_circle_rounded, size: 24),
              label: Text(
                'Confirm Payment Sent',
                style: AppTextStyles.button.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                backgroundColor: AppColors.success,
                foregroundColor: AppColors.white,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space12),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelPayment,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                side: BorderSide(color: AppColors.error, width: 2),
                foregroundColor: AppColors.error,
              ),
              child: Text(
                'Cancel Payment',
                style: AppTextStyles.button.copyWith(
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
