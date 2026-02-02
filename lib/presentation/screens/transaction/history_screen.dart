import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/formatters.dart';
import '../../../domain/entities/transaction.dart';
import '../../../injection_container.dart';
import '../../bloc/transaction/transaction_bloc.dart';
import '../../bloc/transaction/transaction_event.dart';
import '../../bloc/transaction/transaction_state.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<TransactionBloc>()..add(const LoadTransactions()),
      child: const _TransactionHistoryView(),
    );
  }
}

class _TransactionHistoryView extends StatefulWidget {
  const _TransactionHistoryView({Key? key}) : super(key: key);

  @override
  State<_TransactionHistoryView> createState() => _TransactionHistoryViewState();
}

class _TransactionHistoryViewState extends State<_TransactionHistoryView> {
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<TransactionBloc>().add(const LoadMoreTransactions());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: TextStyle(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<TransactionBloc>().add(const LoadTransactions());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is TransactionLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TransactionBloc>().add(const RefreshTransactions());
              },
              child: _buildTransactionList(state),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildTransactionList(TransactionLoaded state) {
    final transactions = state.filteredTransactions;
    
    if (transactions.isEmpty) {
      return ListView(
        children: [
          _buildSummaryCard(transactions),
          const SizedBox(height: 24),
          _buildFilterChips(),
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'No transactions yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Group transactions by date
    final groupedTransactions = _groupTransactionsByDate(transactions);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: groupedTransactions.length + 2 + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == 0) {
          return _buildSummaryCard(transactions);
        }
        if (index == 1) {
          return Column(
            children: [
              const SizedBox(height: 24),
              _buildFilterChips(),
              const SizedBox(height: 16),
            ],
          );
        }
        
        final sectionIndex = index - 2;
        if (sectionIndex >= groupedTransactions.length) {
          // Loading more indicator
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final entry = groupedTransactions.entries.elementAt(sectionIndex);
        return _buildDateSection(entry.key, entry.value);
      },
    );
  }

  Map<String, List<Transaction>> _groupTransactionsByDate(List<Transaction> transactions) {
    final Map<String, List<Transaction>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in transactions) {
      final txDate = DateTime(tx.createdAt.year, tx.createdAt.month, tx.createdAt.day);
      String dateLabel;

      if (txDate == today) {
        dateLabel = 'Today';
      } else if (txDate == yesterday) {
        dateLabel = 'Yesterday';
      } else if (now.difference(txDate).inDays < 7) {
        dateLabel = 'This Week';
      } else {
        dateLabel = Formatters.formatDate(tx.createdAt);
      }

      grouped.putIfAbsent(dateLabel, () => []).add(tx);
    }

    return grouped;
  }

  Widget _buildSummaryCard(List<Transaction> transactions) {
    double totalReceived = 0;
    double totalSent = 0;

    for (final tx in transactions) {
      final isCredit = tx.merchantWalletId != 'external' && 
                       tx.payerWalletId == 'external' ||
                       tx.transactionType.toLowerCase() == 'topup';
      if (isCredit) {
        totalReceived += tx.amount;
      } else {
        totalSent += tx.amount;
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
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
          const Text(
            'Summary',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Received', totalReceived, Icons.arrow_downward, Colors.green),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem('Sent', totalSent, Icons.arrow_upward, Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, double amount, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            Formatters.formatCurrency(amount),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['All', 'Received', 'Sent', 'Top-up'];
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
                context.read<TransactionBloc>().add(
                  FilterTransactions(filter.toLowerCase().replaceAll('-', '')),
                );
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              labelStyle: TextStyle(
                color: isSelected ? Colors.blue[700] : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDateSection(String date, List<Transaction> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.grey[800],
            ),
          ),
        ),
        ...transactions.map((tx) => _buildTransactionItem(tx)),
      ],
    );
  }

  Widget _buildTransactionItem(Transaction tx) {
    // Determine if this is a credit (money received) or debit (money sent)
    final isCredit = tx.transactionType.toLowerCase() == 'topup' ||
                     (tx.metadata?['direction'] == 'incoming');
    
    final title = isCredit ? 'Payment Received' : 'Payment Sent';
    final merchantName = tx.metadata?['merchantName'] as String? ?? 
                        (isCredit ? 'NFC Payment' : 'Payment');

    Color statusColor;
    IconData statusIcon;

    switch (tx.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'pending':
        statusColor = Colors.orange;
        statusIcon = Icons.hourglass_empty;
        break;
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help;
    }

    return GestureDetector(
      onTap: () {
        _showTransactionDetail(tx);
      },
      child: Container(
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
            // Icon
            Container(
              padding: const EdgeInsets.all(10),
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

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        merchantName,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(statusIcon, size: 14, color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Formatters.formatRelativeTime(tx.createdAt),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Amount
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isCredit ? '+' : '-'}${Formatters.formatCurrency(tx.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isCredit ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(Transaction tx) {
    final isCredit = tx.transactionType.toLowerCase() == 'topup' ||
                     (tx.metadata?['direction'] == 'incoming');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCredit
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                color: isCredit ? Colors.green : Colors.red,
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${isCredit ? '+' : '-'}${Formatters.formatCurrency(tx.amount)}',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: isCredit ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              tx.isCompleted ? 'Completed' : tx.status,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Type', tx.transactionType.toUpperCase()),
            _buildDetailRow('Date', Formatters.formatDateTime(tx.createdAt)),
            _buildDetailRow('Transaction ID', tx.id.substring(0, 8) + '...'),
            if (tx.metadata?['merchantName'] != null)
              _buildDetailRow('Merchant', tx.metadata!['merchantName']),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
