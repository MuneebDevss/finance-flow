import 'package:finance/Features/Debts/Domain/debt_entity.dart';
import 'package:flutter/material.dart';

import 'dart:math' show max;
class DebtStatisticsCard extends StatelessWidget {
  final List<Debt> debts;
  final String preferedAmount;
  const DebtStatisticsCard({super.key, required this.debts, required this.preferedAmount});

  @override
Widget build(BuildContext context) {
  final totalDebt = debts.fold<double>(0, (sum, debt) => sum + debt.remainingBalance);
  final averageDebt =totalDebt==0.0?0.0: totalDebt / debts.length;
  final highestDebt = totalDebt==0.0?0.0:debts.map((d) => d.remainingBalance).reduce(max);
  
  return Container(
    padding: const EdgeInsets.symmetric(horizontal:  16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debt Statistics',
          style: Theme.of(context).textTheme.headlineSmall
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.analytics_outlined,
                label: 'Average',
                value: averageDebt,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.arrow_upward_rounded,
                label: 'Highest',
                value: highestDebt,
                color: Colors.red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                icon: Icons.account_balance_wallet_outlined,
                label: 'Total',
                value: totalDebt,
                color: Colors.green,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildStatCard(
  BuildContext context, {
  required IconData icon,
  required String label,
  required double value,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Color(0xFF49243E),
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${value.toStringAsFixed(2)} $preferedAmount',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
}