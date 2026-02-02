import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nfc/nfc_bloc.dart';
import '../../bloc/nfc/nfc_event.dart';
import '../../bloc/nfc/nfc_state.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/wallet/wallet_bloc.dart';
import '../../bloc/wallet/wallet_event.dart';
import '../../bloc/wallet/wallet_state.dart';
import '../../../domain/entities/wallet.dart';
import '../../../domain/entities/transaction.dart';
import '../../bloc/auth/auth_state.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_theme.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/balance_card_widget.dart';
import '../../widgets/virtual_card_widget.dart';
import '../../widgets/quick_action_grid.dart';
import '../../widgets/transaction_success_overlay.dart';
import '../../widgets/animated_transaction_item.dart';
import '../../widgets/shimmer_loading.dart';
import '../nfc/pay_screen.dart';
import '../nfc/receive_screen.dart';
import '../nfc/nfc_payment_screen.dart';
import '../transaction/history_screen.dart';
import '../settings/settings_screen.dart';

/// Dashboard Screen - RedotPay-inspired Wallet Home
/// Professional fintech UI with balance card, virtual card, and quick actions
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _isCardVisible = true;

  /// Get username from AuthBloc state
  String get userName {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      return authState.fullName;
    }
    return 'User';
  }

  @override
  void initState() {
    super.initState();
    // Load wallet data
    context.read<WalletBloc>().add(LoadWallet());
    
    // Check NFC availability on startup
    context.read<NfcBloc>().add(CheckNfcAvailability());
    
    // Listen to NFC events and trigger wallet updates
    _listenToNfcEvents();
  }

  void _listenToNfcEvents() {
    context.read<NfcBloc>().stream.listen((nfcState) {
      if (nfcState is ReaderTagDetected && mounted) {
        final token = (nfcState as ReaderTagDetected).token;
        
        context.read<WalletBloc>().add(
          NfcTransactionCompleted(
            amount: 50.00,
            isCredit: true,
            merchantName: 'NFC Payment - $token',
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: _buildAppBar(l10n, isDark),
      body: MultiBlocListener(
        listeners: [
          // NFC Event Listener
          BlocListener<NfcBloc, NfcState>(
            listener: (context, state) {
              if (state is NfcUnavailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.reason),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                );
              } else if (state is NfcFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                  ),
                );
              }
            },
          ),
          // Wallet Event Listener - shows success overlay and handles errors
          BlocListener<WalletBloc, WalletState>(
            listener: (context, state) {
              if (state is WalletTransactionSuccess) {
                // Haptic feedback
                HapticFeedback.mediumImpact();
                
                // Show success overlay
                TransactionSuccessOverlay.show(
                  context,
                  amount: state.amount,
                  isCredit: state.isCredit,
                );
              } else if (state is WalletError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    action: SnackBarAction(
                      label: 'Retry',
                      textColor: AppColors.white,
                      onPressed: () {
                        context.read<WalletBloc>().add(LoadWallet());
                      },
                    ),
                  ),
                );
              }
            },
          ),
        ],
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WalletBloc>().add(LoadWallet());
            await Future.delayed(const Duration(seconds: 1));
          },
          color: AppColors.primaryBlue,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppTheme.space8),
                
                // Balance Card
                _buildBalanceCard(),

                const SizedBox(height: AppTheme.space16),

                // Virtual Card Preview (Collapsible)
                if (_isCardVisible) _buildVirtualCard(),

                const SizedBox(height: AppTheme.space24),

                // Quick Actions Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.space16),
                  child: Text(
                    l10n.quickActions,
                    style: AppTextStyles.headlineSmall.copyWith(
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),

                const SizedBox(height: AppTheme.space16),

                // Quick Actions Grid
                _buildQuickActions(l10n),

                const SizedBox(height: AppTheme.space32),

                // Recent Transactions
                _buildRecentTransactions(l10n, isDark),

                const SizedBox(height: AppTheme.space24),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  PreferredSizeWidget _buildAppBar(AppLocalizations l10n, bool isDark) {
    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.space8),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: const Icon(
              Icons.account_balance_wallet_rounded,
              color: AppColors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: AppTheme.space12),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appName,
                  style: AppTextStyles.titleLarge.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Secure Payments',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // TODO: Implement notifications
          },
          tooltip: 'Notifications',
        ),
        const LanguageSwitcher(),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: l10n.settings,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        // Handle loading state
        if (walletState is WalletLoading) {
          return const BalanceCardShimmer();
        }

        // Extract balance from current state
        double balance = 0.0; // No default - show actual balance
        
        if (walletState is WalletLoaded) {
          balance = walletState.balance;
        } else if (walletState is WalletTransactionSuccess) {
          balance = walletState.balance;
        }
        
        return BalanceCardWidget(
          balance: balance,
          currency: 'ج.س',
          userName: userName,
          isActive: true,
          onTap: () {
            setState(() {
              _isCardVisible = !_isCardVisible;
            });
          },
        );
      },
    );
  }

  Widget _buildVirtualCard() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: VirtualCardWidget(
        cardNumber: '4532123456781234',
        expiryDate: '12/26',
        cardHolderName: userName,
        isFrozen: false,
        onTap: () {
          // TODO: Implement card details view
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Card details coming soon'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickActions(AppLocalizations l10n) {
    final actions = [
      QuickAction(
        id: 'send',
        icon: Icons.send_rounded,
        label: 'Pay',
        color: AppColors.primaryBlue,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NfcPaymentScreen(
                mode: NfcPaymentMode.pay,
              ),
            ),
          );
        },
      ),
      QuickAction(
        id: 'receive',
        icon: Icons.download_rounded,
        label: 'Receive',
        color: AppColors.success,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NfcPaymentScreen(
                mode: NfcPaymentMode.receive,
              ),
            ),
          );
        },
      ),
      QuickAction(
        id: 'nfc_pay',
        icon: Icons.nfc_rounded,
        label: 'NFC Pay',
        color: AppColors.secondaryPurple,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NfcPaymentScreen(
                mode: NfcPaymentMode.pay,
              ),
            ),
          );
        },
      ),
      QuickAction(
        id: 'history',
        icon: Icons.history_rounded,
        label: 'History',
        color: AppColors.warning,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const TransactionHistoryScreen(),
            ),
          );
        },
      ),
    ];

    return QuickActionGrid(
      actions: actions,
      crossAxisCount: 2,
    );
  }

  Widget _buildRecentTransactions(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.recentTransactions,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const TransactionHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(l10n.viewAll),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.space12),
          
          // Real transactions from backend
          BlocBuilder<WalletBloc, WalletState>(
            builder: (context, state) {
              // Loading state
              if (state is WalletLoading) {
                return Column(
                  children: const [
                    TransactionItemShimmer(),
                    TransactionItemShimmer(),
                    TransactionItemShimmer(),
                  ],
                );
              }
              
              // Get transactions from wallet state
              List<Transaction> transactions = [];
              String currentWalletId = '';
              
              if (state is WalletLoaded) {
                transactions = state.transactions;
                currentWalletId = state.id;
              } else if (state is WalletTransactionSuccess) {
                transactions = state.transactions;
                currentWalletId = state.id;
              }
              
              // Empty state
              if (transactions.isEmpty) {
                return _buildEmptyTransactions(isDark);
              }
              
              // Show up to 3 recent transactions
              final recentTransactions = transactions.take(3).toList();
              
              return Column(
                children: recentTransactions.map((transaction) {
                  final isCredit = transaction.merchantWalletId == currentWalletId;
                  final merchantName = transaction.metadata?['merchantName'] as String? ?? 
                    (isCredit ? 'Payment Received' : 'Payment Sent');
                  
                  return _buildTransactionItem(
                    icon: isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    title: _getTransactionTitle(transaction.transactionType, isCredit),
                    subtitle: merchantName,
                    amount: transaction.amount,
                    isCredit: isCredit,
                    date: transaction.createdAt,
                    isDark: isDark,
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTransactions(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.space32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 48,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: AppTheme.space12),
            Text(
              'No transactions yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppTheme.space4),
            Text(
              'Your recent transactions will appear here',
              style: AppTextStyles.bodySmall.copyWith(
                color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getTransactionTitle(String transactionType, bool isCredit) {
    switch (transactionType) {
      case 'nfc_payment':
      case 'nfc':
        return isCredit ? 'NFC Payment Received' : 'NFC Payment';
      case 'topup':
        return 'Wallet Top-up';
      case 'transfer':
        return isCredit ? 'Transfer Received' : 'Transfer Sent';
      default:
        return isCredit ? 'Payment Received' : 'Payment Sent';
    }
  }

  Widget _buildTransactionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double amount,
    required bool isCredit,
    required DateTime date,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.space12),
      padding: const EdgeInsets.all(AppTheme.space16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.cardShadow(),
        border: Border.all(
          color: isDark
              ? AppColors.grey700.withOpacity(0.5)
              : AppColors.grey200.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(AppTheme.space12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isCredit
                    ? [AppColors.success.withOpacity(0.2), AppColors.success.withOpacity(0.1)]
                    : [AppColors.error.withOpacity(0.2), AppColors.error.withOpacity(0.1)],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 24,
            ),
          ),

          const SizedBox(width: AppTheme.space12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.titleMedium.copyWith(
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatRelativeTime(date),
                  style: AppTextStyles.labelSmall.copyWith(
                    color: isDark
                        ? AppColors.textTertiaryDark
                        : AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            '${isCredit ? '+' : '-'}${Formatters.formatCurrency(amount)}',
            style: AppTextStyles.transactionAmount.copyWith(
              color: isCredit ? AppColors.success : AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _triggerTestTransaction(double amount) {
    context.read<WalletBloc>().add(
      NfcTransactionCompleted(
        amount: amount,
        isCredit: true,
        merchantName: 'Test Payment',
      ),
    );
  }

  void _showTestTransactionDialog() {
    final TextEditingController amountController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Simulate NFC Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter amount to receive:'),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixText: 'ج.س ',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _handleTestTransaction(amount);
              }
            },
            child: const Text('Simulate'),
          ),
        ],
      ),
    );
  }

  void _handleTestTransaction(double amount) {
    final nfcState = context.read<NfcBloc>().state;
    
    if (nfcState is NfcUnavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('NFC Unavailable: ${nfcState.reason}. Running simulation anyway...'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } else if (nfcState is NfcAvailable || nfcState is ReaderActive || nfcState is ReaderWaitingForTag) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ NFC Active. processing transaction...'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 1),
        ),
      );
    } else {
       // Check triggered but proceeding
       context.read<NfcBloc>().add(CheckNfcAvailability());
    }
    
    _triggerTestTransaction(amount);
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: () {
        _showTestTransactionDialog();
      },
      icon: const Icon(Icons.nfc),
      label: const Text('Test NFC'),
      backgroundColor: AppColors.primaryTeal,
      foregroundColor: AppColors.black,
    );
  }
}
