import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nfc/nfc_bloc.dart';
import '../../bloc/nfc/nfc_event.dart';
import '../../bloc/nfc/nfc_state.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/nfc_pulse_indicator.dart';

/// NFC Payment Mode
enum NfcPaymentMode {
  pay,     // Sender - paying money
  receive, // Receiver - receiving money
}

/// Transaction Status
enum TransactionStatus {
  idle,
  preparing,
  ready,
  connecting,
  processing,
  success,
  failed,
}

/// Unified NFC Payment Screen
/// Handles both sending and receiving payments with automatic flow
class NfcPaymentScreen extends StatefulWidget {
  final NfcPaymentMode mode;
  final double? presetAmount; // Optional preset amount for receive mode

  const NfcPaymentScreen({
    Key? key,
    required this.mode,
    this.presetAmount,
  }) : super(key: key);

  @override
  State<NfcPaymentScreen> createState() => _NfcPaymentScreenState();
}

class _NfcPaymentScreenState extends State<NfcPaymentScreen>
    with TickerProviderStateMixin {
  final TextEditingController _amountController = TextEditingController();
  
  late AnimationController _pulseController;
  late AnimationController _successController;
  late Animation<double> _successScale;
  late Animation<double> _checkOpacity;
  
  TransactionStatus _status = TransactionStatus.idle;
  double _amount = 0.0;
  String? _errorMessage;
  String? _transactionId;
  String? _payerInfo;
  
  // For receive mode
  StreamSubscription? _nfcSubscription;

  @override
  void initState() {
    super.initState();
    
    // Initialize animations
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    
    _successController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _successScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: Curves.elasticOut,
      ),
    );
    
    _checkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Set preset amount if provided
    if (widget.presetAmount != null) {
      _amountController.text = widget.presetAmount!.toStringAsFixed(2);
    }
    
    // Auto-start for receive mode
    if (widget.mode == NfcPaymentMode.receive) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.presetAmount != null && widget.presetAmount! > 0) {
          _startTransaction();
        }
      });
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _nfcSubscription?.cancel();
    _stopNfc();
    super.dispose();
  }

  void _stopNfc() {
    if (widget.mode == NfcPaymentMode.receive) {
      context.read<NfcBloc>().add(StopReaderMode());
    } else {
      context.read<NfcBloc>().add(DisableHceMode());
    }
  }

  void _playSuccessSound() {
    // Play system notification sound
    SystemSound.play(SystemSoundType.click);
  }

  void _vibrate({bool heavy = false}) {
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.mediumImpact();
    }
  }

  void _startTransaction() {
    final l10n = AppLocalizations.of(context);
    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      _showError(l10n?.translate('enter_valid_amount') ?? 'Please enter a valid amount');
      return;
    }

    final walletState = context.read<WalletBloc>().state;
    if (walletState is! WalletLoaded) {
      _showError('Wallet not loaded');
      return;
    }

    // Check balance for pay mode
    if (widget.mode == NfcPaymentMode.pay && walletState.balance < amount) {
      _showError(l10n?.translate('insufficient_balance') ?? 'Insufficient balance');
      return;
    }

    setState(() {
      _amount = amount;
      _status = TransactionStatus.preparing;
      _errorMessage = null;
    });

    _vibrate();

    // Generate transaction ID
    _transactionId = 'TXN_${DateTime.now().millisecondsSinceEpoch}';

    if (widget.mode == NfcPaymentMode.pay) {
      _initializePayMode(walletState);
    } else {
      _initializeReceiveMode();
    }
  }

  void _initializePayMode(WalletLoaded walletState) {
    setState(() {
      _status = TransactionStatus.ready;
    });

    // Enable HCE with payment token
    context.read<NfcBloc>().add(
      EnableHceMode(
        userId: walletState.userId,
        walletId: walletState.id,
        deviceId: 'device_${walletState.userId}',
        amount: _amount,
      ),
    );
  }

  void _initializeReceiveMode() {
    setState(() {
      _status = TransactionStatus.ready;
    });

    // Start NFC reader mode
    context.read<NfcBloc>().add(StartReaderMode());
  }

  void _processReceivedToken(String encryptedToken) {
    print('📥 NfcPaymentScreen: _processReceivedToken called');
    print('   - Token length: ${encryptedToken.length}');
    
    if (_status == TransactionStatus.processing || 
        _status == TransactionStatus.success) {
      print('⚠️ Already processing or success, skipping');
      return;
    }

    setState(() {
      _status = TransactionStatus.processing;
    });

    _vibrate();

    try {
      // Decode token to get amount info (for display)
      final bytes = base64Decode(encryptedToken);
      final decoded = utf8.decode(bytes);
      final tokenData = jsonDecode(decoded);

      final amount = (tokenData['amount'] as num?)?.toDouble() ?? 0.0;
      final userId = tokenData['userId'] as String? ?? 'Unknown';

      print('📥 Token decoded: amount=$amount, userId=$userId');

      setState(() {
        _amount = amount;
        _payerInfo = userId;
      });

      // Process successful payment - pass the encrypted token for backend validation
      _completeTransaction(isCredit: true, amount: amount, token: encryptedToken);
      
    } catch (e) {
      print('❌ Token decode error: $e');
      _handleError('Invalid payment data: $e');
    }
  }

  void _confirmPayment() {
    print('🔘 NfcPaymentScreen: _confirmPayment called, current status: $_status');
    if (_status != TransactionStatus.ready && _status != TransactionStatus.connecting) {
      print('⚠️ NfcPaymentScreen: Invalid status for confirm, ignoring');
      return;
    }

    setState(() {
      _status = TransactionStatus.processing;
    });

    // Complete the payment (debit)
    print('💸 NfcPaymentScreen: Completing payment - amount: $_amount');
    _completeTransaction(isCredit: false, amount: _amount);
  }

  void _completeTransaction({required bool isCredit, required double amount, String? token}) {
    print('✅ NfcPaymentScreen: _completeTransaction called');
    print('   - isCredit: $isCredit');
    print('   - amount: $amount');
    print('   - mode: ${widget.mode}');
    print('   - token: ${token != null ? "provided (${token.length} chars)" : "null"}');
    
    // Update wallet - pass token for backend validation (receiver needs this)
    print('📤 NfcPaymentScreen: Sending NfcTransactionCompleted to WalletBloc');
    context.read<WalletBloc>().add(NfcTransactionCompleted(
      amount: amount,
      isCredit: isCredit,
      merchantName: isCredit ? 'NFC Payment Received' : 'NFC Payment Sent',
      token: token, // Pass token for backend validation
    ));

    // Stop NFC
    _stopNfc();

    // Show success
    setState(() {
      _status = TransactionStatus.success;
    });

    // Play success feedback
    _vibrate(heavy: true);
    _playSuccessSound();
    _successController.forward();

    print('🎉 NfcPaymentScreen: Success animation started');

    // Auto-close after delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pop(true); // Return true for success
      }
    });
  }

  void _handleError(String message) {
    setState(() {
      _status = TransactionStatus.failed;
      _errorMessage = message;
    });
    _vibrate(heavy: true);
    _stopNfc();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _retry() {
    setState(() {
      _status = TransactionStatus.idle;
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context) ?? AppLocalizations(const Locale('en'));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPay = widget.mode == NfcPaymentMode.pay;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isPay ? l10n.translate('pay') : l10n.translate('receive'),
          style: AppTextStyles.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () {
            _stopNfc();
            Navigator.pop(context);
          },
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<NfcBloc, NfcState>(
            listener: (context, state) {
              print('🎯 NfcPaymentScreen: NfcState changed to ${state.runtimeType}');
              
              if (state is ReaderTagDetected && widget.mode == NfcPaymentMode.receive) {
                _processReceivedToken(state.token);
              } else if (state is HcePaymentSent && widget.mode == NfcPaymentMode.pay) {
                // Auto-complete payment when token is successfully sent
                print('✅ NfcPaymentScreen: HcePaymentSent received! Amount: ${state.amount}');
                if (_status == TransactionStatus.ready || _status == TransactionStatus.connecting) {
                  setState(() {
                    _status = TransactionStatus.processing;
                  });
                  _completeTransaction(isCredit: false, amount: state.amount);
                }
              } else if (state is NfcFailureState) {
                _handleError(state.message);
              }
            },
          ),
          BlocListener<WalletBloc, WalletState>(
            listener: (context, state) {
              print('💰 NfcPaymentScreen: WalletState changed to ${state.runtimeType}');
              if (state is WalletTransactionSuccess) {
                print('💰 WalletTransactionSuccess: amount=${state.amount}, isCredit=${state.isCredit}');
              }
            },
          ),
        ],
        child: SafeArea(
          child: _buildContent(isDark, l10n),
        ),
      ),
    );
  }

  Widget _buildContent(bool isDark, AppLocalizations l10n) {
    switch (_status) {
      case TransactionStatus.idle:
        return _buildAmountInput(isDark, l10n);
      case TransactionStatus.preparing:
        return _buildPreparingView(isDark, l10n);
      case TransactionStatus.ready:
      case TransactionStatus.connecting:
        return _buildReadyView(isDark, l10n);
      case TransactionStatus.processing:
        return _buildProcessingView(isDark, l10n);
      case TransactionStatus.success:
        return _buildSuccessView(isDark, l10n);
      case TransactionStatus.failed:
        return _buildFailedView(isDark, l10n);
    }
  }

  Widget _buildAmountInput(bool isDark, AppLocalizations l10n) {
    final isPay = widget.mode == NfcPaymentMode.pay;
    final color = isPay ? AppColors.primaryBlue : AppColors.success;

    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        double balance = 0.0;
        if (walletState is WalletLoaded) {
          balance = walletState.balance;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppTheme.space16),

              // Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Icon(
                  isPay ? Icons.payment_rounded : Icons.download_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),

              const SizedBox(height: AppTheme.space24),

              // Title
              Text(
                isPay 
                    ? l10n.translate('enter_payment_amount')
                    : l10n.translate('enter_receive_amount'),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
                textAlign: TextAlign.center,
              ),

              if (isPay) ...[
                const SizedBox(height: AppTheme.space8),
                Text(
                  '${l10n.translate('available_balance')}: ${Formatters.formatCurrency(balance)}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: AppTheme.space32),

              // Amount Input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space24,
                  vertical: AppTheme.space32,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.cardDark : AppColors.cardLight,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'SDG',
                      style: AppTextStyles.titleMedium.copyWith(
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    TextField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                      decoration: InputDecoration(
                        hintText: '0.00',
                        hintStyle: TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
                        ),
                        border: InputBorder.none,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppTheme.space32),

              // Quick amounts
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [10, 50, 100, 500].map((amount) {
                  return _QuickAmountButton(
                    amount: amount,
                    color: color,
                    onTap: () {
                      _amountController.text = amount.toString();
                      _vibrate();
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: AppTheme.space48),

              // Continue Button
              ElevatedButton(
                onPressed: _startTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  elevation: 8,
                  shadowColor: color.withOpacity(0.4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(isPay ? Icons.nfc_rounded : Icons.contactless_rounded, size: 28),
                    const SizedBox(width: AppTheme.space12),
                    Text(
                      isPay 
                          ? l10n.translate('continue_to_pay')
                          : l10n.translate('start_receiving'),
                      style: AppTextStyles.button.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
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

  Widget _buildPreparingView(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: AppTheme.space24),
          Text(
            l10n.translate('preparing_transaction'),
            style: AppTextStyles.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildReadyView(bool isDark, AppLocalizations l10n) {
    final isPay = widget.mode == NfcPaymentMode.pay;
    final color = isPay ? AppColors.primaryBlue : AppColors.success;

    return Container(
      padding: const EdgeInsets.all(AppTheme.space24),
      child: Column(
        children: [
          // Amount Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.space24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  isPay ? l10n.translate('paying') : l10n.translate('receiving'),
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.space8),
                Text(
                  Formatters.formatCurrency(_amount),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space48),

          // NFC Animation
          Expanded(
            child: Center(
              child: NfcPulseIndicator(
                state: NfcPulseState.listening,
                size: 240,
              ),
            ),
          ),

          // Instructions
          Container(
            padding: const EdgeInsets.all(AppTheme.space16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  isPay ? Icons.tap_and_play_rounded : Icons.phonelink_ring_rounded,
                  color: color,
                  size: 32,
                ),
                const SizedBox(width: AppTheme.space16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isPay 
                            ? l10n.translate('tap_to_pay')
                            : l10n.translate('waiting_for_payment'),
                        style: AppTextStyles.titleMedium.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPay 
                            ? l10n.translate('hold_near_receiver')
                            : l10n.translate('ask_customer_tap'),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppTheme.space24),

          // Action Buttons
          if (isPay) ...[
            // Confirm button for payer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _confirmPayment,
                icon: const Icon(Icons.check_circle_rounded),
                label: Text(l10n.translate('confirm_payment_sent')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.space12),
          ],

          // Cancel button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _stopNfc();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error, width: 2),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
              child: Text(l10n.translate('cancel')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProcessingView(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 120,
            height: 120,
            child: CircularProgressIndicator(
              strokeWidth: 6,
              valueColor: AlwaysStoppedAnimation<Color>(
                widget.mode == NfcPaymentMode.pay 
                    ? AppColors.primaryBlue 
                    : AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.space32),
          Text(
            l10n.translate('processing_payment'),
            style: AppTextStyles.headlineMedium,
          ),
          const SizedBox(height: AppTheme.space12),
          Text(
            l10n.translate('please_wait'),
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark, AppLocalizations l10n) {
    final isPay = widget.mode == NfcPaymentMode.pay;
    final color = AppColors.success;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Success Animation
          ScaleTransition(
            scale: _successScale,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
              ),
              child: FadeTransition(
                opacity: _checkOpacity,
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space32),

          // Success Message
          Text(
            isPay 
                ? l10n.translate('payment_successful')
                : l10n.translate('payment_received'),
            style: AppTextStyles.headlineLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.space16),

          // Amount
          Text(
            '${isPay ? "-" : "+"} ${Formatters.formatCurrency(_amount)}',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: isPay ? AppColors.error : AppColors.success,
            ),
          ),

          const SizedBox(height: AppTheme.space16),

          // Description
          Text(
            isPay 
                ? l10n.translate('amount_deducted_successfully')
                : l10n.translate('payment_received_successfully'),
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          if (_payerInfo != null) ...[
            const SizedBox(height: AppTheme.space8),
            Text(
              'From: ${_payerInfo!.substring(0, _payerInfo!.length > 12 ? 12 : _payerInfo!.length)}...',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
          ],

          const SizedBox(height: AppTheme.space48),

          // Done Button
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.space48,
                vertical: AppTheme.space16,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
            child: Text(l10n.translate('done')),
          ),
        ],
      ),
    );
  }

  Widget _buildFailedView(bool isDark, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.space24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: AppColors.error,
                size: 64,
              ),
            ),

            const SizedBox(height: AppTheme.space32),

            Text(
              l10n.translate('payment_failed'),
              style: AppTextStyles.headlineLarge.copyWith(
                color: AppColors.error,
              ),
            ),

            const SizedBox(height: AppTheme.space16),

            Text(
              _errorMessage ?? l10n.translate('unknown_error'),
              style: AppTextStyles.bodyLarge.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppTheme.space48),

            // Retry Button
            ElevatedButton.icon(
              onPressed: _retry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(l10n.translate('try_again')),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space32,
                  vertical: AppTheme.space16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.space16),

            // Cancel Button
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.translate('cancel')),
            ),
          ],
        ),
      ),
    );
  }
}

/// Quick Amount Button Widget
class _QuickAmountButton extends StatelessWidget {
  final int amount;
  final Color color;
  final VoidCallback onTap;

  const _QuickAmountButton({
    required this.amount,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.space16,
            vertical: AppTheme.space12,
          ),
          child: Text(
            '$amount',
            style: AppTextStyles.titleMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
