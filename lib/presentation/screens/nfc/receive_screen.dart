import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nfc/nfc_bloc.dart';
import '../../bloc/nfc/nfc_event.dart';
import '../../bloc/nfc/nfc_state.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/nfc_pulse_indicator.dart';
import '../../widgets/transaction_success_overlay.dart';
import 'dart:convert';

/// Receive Screen - Merchant receives payment via NFC
/// Simply listens for NFC and extracts amount from payer's token
class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  bool _isListening = false;
  bool _isProcessing = false;
  double? _receivedAmount;

  @override
  void initState() {
    super.initState();
    // Auto-start listening when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startListening();
    });
  }

  @override
  void dispose() {
    if (_isListening) {
      try {
        context.read<NfcBloc>().add(StopReaderMode());
      } catch (e) {
        debugPrint('Error stopping reader mode: $e');
      }
    }
    super.dispose();
  }

  void _startListening() {
    debugPrint('🎧 Starting NFC listener...');
    setState(() {
      _isListening = true;
      _isProcessing = false;
      _receivedAmount = null;
    });

    context.read<NfcBloc>().add(StartReaderMode());
    HapticFeedback.mediumImpact();
  }

  void _stopListening() {
    debugPrint('🛑 Stopping NFC listener...');
    setState(() {
      _isListening = false;
      _isProcessing = false;
    });
    context.read<NfcBloc>().add(StopReaderMode());
  }

  void _processToken(String token) {
    debugPrint('🔄 Processing token...');
    debugPrint('📦 Token length: ${token.length}');
    debugPrint('📝 Token preview: ${token.substring(0, token.length > 80 ? 80 : token.length)}...');
    
    setState(() {
      _isProcessing = true;
    });

    // Decode the token to extract amount
    try {
      debugPrint('🔓 Decoding base64...');
      final bytes = base64Decode(token);
      debugPrint('📊 Decoded ${bytes.length} bytes');
      
      final decoded = utf8.decode(bytes);
      debugPrint('📄 JSON string: $decoded');
      
      final tokenData = jsonDecode(decoded);
      debugPrint('✅ JSON parsed successfully!');
      debugPrint('📋 Token data: $tokenData');
      
      final amount = (tokenData['amount'] as num?)?.toDouble() ?? 0.0;
      debugPrint('💰 Amount extracted: $amount');
      
      setState(() {
        _receivedAmount = amount;
      });

      // Show success overlay
      _showSuccess(amount);
      
    } catch (e, stackTrace) {
      debugPrint('❌ Error processing token: $e');
      debugPrint('📚 Stack trace: $stackTrace');
      _showError('Failed to read payment: $e');
    }
  }

  void _showSuccess(double amount) {
    debugPrint('🎉 Showing success overlay for amount: $amount');
    HapticFeedback.heavyImpact();
    _stopListening();
    
    // Update wallet balance (credit) - this will update the balance locally
    context.read<WalletBloc>().add(NfcTransactionCompleted(
      amount: amount,
      isCredit: true, // Receiving money
      merchantName: 'NFC Payment Received',
    ));
    
    // Show the beautiful success overlay
    TransactionSuccessOverlay.show(
      context,
      amount: amount,
      isCredit: true,
    );
    
    // Go back after overlay dismisses
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _showError(String error) {
    debugPrint('❌ Showing error: $error');
    HapticFeedback.heavyImpact();
    
    setState(() {
      _isProcessing = false;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Retry',
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              _isProcessing = false;
            });
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Receive Payment',
          style: AppTextStyles.titleLarge,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () {
            _stopListening();
            Navigator.pop(context);
          },
        ),
      ),
      body: BlocListener<NfcBloc, NfcState>(
        listener: (context, state) {
          debugPrint('📡 NFC State changed: ${state.runtimeType}');
          
          if (state is ReaderTagDetected) {
            debugPrint('🏷️ Tag detected with token!');
            if (!_isProcessing) {
              _processToken(state.token);
            }
          } else if (state is NfcFailureState) {
            debugPrint('❌ NFC Failure: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
          } else if (state is ReaderWaitingForTag) {
            debugPrint('👂 Reader is now waiting for tag...');
          }
        },
        child: BlocBuilder<NfcBloc, NfcState>(
          builder: (context, nfcState) {
            return _buildListeningView(nfcState, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildListeningView(NfcState nfcState, bool isDark) {
    NfcPulseState pulseState = NfcPulseState.listening;
    String statusText = 'Waiting for Payment...';
    String subtitleText = 'Ask the customer to tap their phone';

    if (_isProcessing) {
      pulseState = NfcPulseState.success;
      statusText = 'Processing Payment...';
      subtitleText = 'Reading payment data';
    } else if (nfcState is ReaderTagDetected) {
      pulseState = NfcPulseState.success;
      statusText = 'Payment Detected!';
      subtitleText = 'Processing...';
    } else if (nfcState is NfcFailureState) {
      pulseState = NfcPulseState.error;
      statusText = 'Error Reading NFC';
      subtitleText = nfcState.message;
    } else if (nfcState is ReaderWaitingForTag) {
      pulseState = NfcPulseState.listening;
      statusText = 'Ready to Receive';
      subtitleText = 'Waiting for customer to tap...';
    } else if (nfcState is ReaderActivating) {
      pulseState = NfcPulseState.listening;
      statusText = 'Activating...';
      subtitleText = 'Getting ready...';
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.space32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Merchant Info Banner
          BlocBuilder<WalletBloc, WalletState>(
            builder: (context, walletState) {
              String balance = '---';
              if (walletState is WalletLoaded) {
                balance = Formatters.formatCurrency(walletState.balance);
              }
              
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.space24,
                  vertical: AppTheme.space16,
                ),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
                  boxShadow: AppTheme.elevatedShadow(color: AppColors.primaryBlue),
                ),
                child: Column(
                  children: [
                    Text(
                      'Your Balance',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: AppTheme.space4),
                    Text(
                      balance,
                      style: AppTextStyles.headlineLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppTheme.space48),

          // NFC Pulse Indicator
          NfcPulseIndicator(
            state: pulseState,
            size: 250,
          ),

          const SizedBox(height: AppTheme.space48),

          // Status Text
          Text(
            statusText,
            style: AppTextStyles.headlineMedium.copyWith(
              color: pulseState == NfcPulseState.success
                  ? AppColors.success
                  : pulseState == NfcPulseState.error
                      ? AppColors.error
                      : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppTheme.space12),

          Text(
            subtitleText,
            style: AppTextStyles.bodyLarge.copyWith(
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),

          // Show received amount if available
          if (_receivedAmount != null) ...[
            const SizedBox(height: AppTheme.space24),
            Container(
              padding: const EdgeInsets.all(AppTheme.space16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: AppColors.success, width: 2),
              ),
              child: Text(
                'Received: ${Formatters.formatCurrency(_receivedAmount!)}',
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],

          const SizedBox(height: AppTheme.space24),

          // Instructions Card
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
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.info.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.phone_android_rounded,
                    color: AppColors.info,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.space12),
                Expanded(
                  child: Text(
                    'Customer enters amount on their phone and taps',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.info,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Debug: Current state display
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'State: ${nfcState.runtimeType}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: AppTheme.space16),

          // Stop Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _stopListening();
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: AppTheme.space16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                side: BorderSide(color: AppColors.error, width: 2),
                foregroundColor: AppColors.error,
              ),
              child: Text(
                'Stop Receiving',
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
