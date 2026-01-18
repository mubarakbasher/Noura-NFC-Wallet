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
import '../../../core/utils/formatters.dart';
import '../../../core/localization/app_localizations.dart';
import '../../widgets/language_switcher.dart';
import '../../widgets/animated_balance.dart';
import '../../widgets/transaction_success_overlay.dart';
import '../../widgets/animated_transaction_item.dart';
import '../nfc/pay_screen.dart';
import '../nfc/receive_screen.dart';
import '../transaction/history_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Mock data - will be replaced with real data later
  final double balance = 1250.50;
  final String userName = "Demo User";

  @override
  void initState() {
    super.initState();
    // Check NFC availability on startup
    context.read<NfcBloc>().add(CheckNfcAvailability());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.appName),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          const LanguageSwitcher(),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TransactionHistoryScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: l10n.logout,
            onPressed: () {
              // Import auth bloc
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          // NFC Event Listener - triggers wallet updates
          BlocListener<NfcBloc, NfcState>(
            listener: (context, state) {
              if (state is NfcUnavailable) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.reason),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                  ),
                );
              } else if (state is NfcFailureState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
          ),
          // Wallet Event Listener - shows success overlay
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
              }
            },
          ),
        ],
        child: BlocBuilder<NfcBloc, NfcState>(
          builder: (context, nfcState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  _buildBalanceCard(),

                  const SizedBox(height: 24),

                  // Quick Actions
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      l10n.quickActions,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Pay and Receive Buttons
                  _buildActionButtons(),

                  const SizedBox(height: 24),

                  // NFC Status
                  _buildNfcStatus(),

                  const SizedBox(height: 24),

                  // Recent Transactions Preview
                  _buildRecentTransactions(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return BlocBuilder<WalletBloc, WalletState>(
      builder: (context, walletState) {
        final balance = walletState is WalletLoaded 
            ? walletState.balance 
            : (walletState is WalletTransactionSuccess ? walletState.wallet.balance : 0.0);
        
        return Builder(
          builder: (innerContext) {
            final l10n = AppLocalizations.of(innerContext)!;
            return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue[700]!, Colors.blue[500]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.availableBalance,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      l10n.active,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Animated Balance
              AnimatedBalanceWidget(
                balance: balance,
                currency: '\$',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.account_circle, color: Colors.white70, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    userName,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
          }
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Builder(
      builder: (context) {
        final l10n = AppLocalizations.of(context)!;
        return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.nfc,
              label: l10n.payWithNfc,
              color: Colors.green,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PayScreen(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildActionButton(
              icon: Icons.qr_code_scanner,
              label: l10n.receivePayment,
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ReceiveScreen(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
      }
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNfcStatus() {
    return BlocBuilder<NfcBloc, NfcState>(
      builder: (context, state) {
        final l10n = AppLocalizations.of(context)!;
        IconData icon;
        String status;
        Color color;

        if (state is NfcAvailable) {
          icon = Icons.check_circle;
          status = l10n.nfcAvailable;
          color = Colors.green;
        } else if (state is NfcUnavailable) {
          icon = Icons.error;
          status = l10n.nfcUnavailable;
          color = Colors.red;
        } else if (state is NfcChecking) {
          icon = Icons.hourglass_empty;
          status = l10n.checkingNfc;
          color = Colors.orange;
        } else {
          icon = Icons.nfc;
          status = l10n.nfcUnknown;
          color = Colors.grey;
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 12),
              Text(
                status,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentTransactions() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return Text(
                    l10n.recentTransactions,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  );
                }
              ),
              Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  return TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TransactionHistoryScreen(),
                        ),
                      );
                    },
                    child: Text(l10n.viewAll),
                  );
                }
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildTransactionItem(
            title: 'Payment Received',
            amount: 50.00,
            isCredit: true,
            date: DateTime.now().subtract(const Duration(hours: 2)),
          ),
          _buildTransactionItem(
            title: 'Payment Sent',
            amount: 25.00,
            isCredit: false,
            date: DateTime.now().subtract(const Duration(days: 1)),
          ),
          _buildTransactionItem(
            title: 'Wallet Top-up',
            amount: 100.00,
            isCredit: true,
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required double amount,
    required bool isCredit,
    required DateTime date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isCredit
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? Colors.green : Colors.red,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Formatters.formatRelativeTime(date),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${Formatters.formatCurrency(amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isCredit ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }
}
