import 'package:flutter/material.dart';
import '../../../core/utils/formatters.dart';

class TransactionHistoryScreen extends StatelessWidget {
  const TransactionHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary Card
          _buildSummaryCard(),

          const SizedBox(height: 24),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All', true),
                const SizedBox(width: 8),
                _buildFilterChip('Received', false),
                const SizedBox(width: 8),
                _buildFilterChip('Sent', false),
                const SizedBox(width: 8),
                _buildFilterChip('Top-up', false),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Transactions
          _buildDateSection('Today', [
            _buildTransactionItem(
              title: 'Payment Received',
              subtitle: 'NFC Payment',
              amount: 50.00,
              isCredit: true,
              time: DateTime.now().subtract(const Duration(hours: 2)),
              status: 'completed',
            ),
            _buildTransactionItem(
              title: 'Payment Sent',
              subtitle: 'Coffee Shop',
              amount: 12.50,
              isCredit: false,
              time: DateTime.now().subtract(const Duration(hours: 5)),
              status: 'completed',
            ),
          ]),

          _buildDateSection('Yesterday', [
            _buildTransactionItem(
              title: 'Payment Sent',
              subtitle: 'Grocery Store',
              amount: 25.00,
              isCredit: false,
              time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
              status: 'completed',
            ),
            _buildTransactionItem(
              title: 'Wallet Top-up',
              subtitle: 'Bank Transfer',
              amount: 100.00,
              isCredit: true,
              time: DateTime.now().subtract(const Duration(days: 1, hours: 10)),
              status: 'completed',
            ),
          ]),

          _buildDateSection('This Week', [
            _buildTransactionItem(
              title: 'Payment Received',
              subtitle: 'NFC Payment',
              amount: 75.00,
              isCredit: true,
              time: DateTime.now().subtract(const Duration(days: 3)),
              status: 'completed',
            ),
            _buildTransactionItem(
              title: 'Payment Sent',
              subtitle: 'Restaurant',
              amount: 45.00,
              isCredit: false,
              time: DateTime.now().subtract(const Duration(days: 4)),
              status: 'completed',
            ),
            _buildTransactionItem(
              title: 'Payment Sent',
              subtitle: 'Gas Station',
              amount: 30.00,
              isCredit: false,
              time: DateTime.now().subtract(const Duration(days: 5)),
              status: 'completed',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
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
            'This Month',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem('Received', 225.00, Icons.arrow_downward, Colors.green),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildSummaryItem('Sent', 112.50, Icons.arrow_upward, Colors.red),
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

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {},
      selectedColor: Colors.blue[100],
      checkmarkColor: Colors.blue[700],
      labelStyle: TextStyle(
        color: isSelected ? Colors.blue[700] : Colors.grey[700],
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildDateSection(String date, List<Widget> transactions) {
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
        ...transactions,
      ],
    );
  }

  Widget _buildTransactionItem({
    required String title,
    required String subtitle,
    required double amount,
    required bool isCredit,
    required DateTime time,
    required String status,
  }) {
    Color statusColor;
    IconData statusIcon;

    switch (status) {
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
                      subtitle,
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
                  Formatters.formatRelativeTime(time),
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
                '${isCredit ? '+' : '-'}${Formatters.formatCurrency(amount)}',
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
    );
  }
}
