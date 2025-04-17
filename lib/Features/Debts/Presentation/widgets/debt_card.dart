import 'dart:ui';

import 'package:finance/Features/Debts/Domain/debt_entity.dart';
import 'package:finance/Features/Debts/Domain/debt_repo.dart';
import 'package:finance/Features/Debts/Presentation/Screens/add_debt.dart';
import 'package:finance/Features/Debts/Presentation/Screens/debt_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// Minimalistic Debt Card
class DebtCard extends StatelessWidget {
  final Debt debt;
  final String preferedAmount;
  
  const DebtCard({
    super.key, 
    required this.debt, 
    required this.preferedAmount
  });

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.redAccent;
    if (progress < 0.7) return Colors.orangeAccent;
    return Colors.greenAccent[700]!;
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (debt.remainingBalance / debt.totalAmount);
    
    final progressColor = _getProgressColor(progress);

    return Dismissible(
      key: Key(debt.id),
      background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red[400],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _showDeleteConfirmation(context, debt.id);
                  },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DebtDetailsScreen(debt: debt, preferedAmount: preferedAmount),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        debt.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      '${(progress * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  minHeight: 4,
                ),
                const SizedBox(height: 8),
                Text(
                  '${debt.remainingBalance.toStringAsFixed(2)} $preferedAmount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: progressColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Debt Details Screen
  Future<void> _showDeleteConfirmation(BuildContext context,String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('Delete Debt'),
        content: Text('Are you sure you want to delete this debt?'),
        actions: [
          TextButton(
            onPressed: () => Get.offAll(()=>DebtListScreen()),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await DebtRepository().deleteDebt(id);
      Get.offAll(()=>DebtListScreen()); // Return to previous screen after deletion
    }
  }
class DebtDetailsScreen extends StatelessWidget {
  final Debt debt;
  final String preferedAmount;

  const DebtDetailsScreen({
    super.key,
    required this.debt,
    required this.preferedAmount,
  });

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.redAccent;
    if (progress < 0.7) return Colors.orangeAccent;
    return Colors.greenAccent[700]!;
  }


  @override
  Widget build(BuildContext context) {
    final progress = 1 - (debt.remainingBalance / debt.totalAmount);
    Theme.of(context);
    final progressColor = _getProgressColor(progress);

    return Scaffold(
      appBar: AppBar(
        title: Text('Debt Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AddEditDebtScreen(debt: debt),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.delete_outline),
            color: Colors.red,
            onPressed: () => _showDeleteConfirmation(context,debt.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                debt.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 24),
              _DetailCard(
                title: 'Progress',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      minHeight: 8,
                    ),
                    SizedBox(height: 8),
                    Text(
                      '${(progress * 100).toStringAsFixed(1)}% paid',
                      style: TextStyle(
                        color: progressColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              _DetailCard(
                title: 'Amount Details',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                      label: 'Remaining Balance',
                      value: '${debt.remainingBalance.toStringAsFixed(2)} $preferedAmount',
                      valueColor: progressColor,
                    ),
                    SizedBox(height: 8),
                    _DetailRow(
                      label: 'Total Amount',
                      value: '${debt.totalAmount.toStringAsFixed(2)} $preferedAmount',
                    ),
                  ],
                ),
              ),
              if (debt.dueDate != null) ...[
                SizedBox(height: 16),
                _DetailCard(
                  title: 'Payment Details',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _DetailRow(
                        label: 'Due Date',
                        value: DateFormat('MMM dd, yyyy').format(debt.dueDate!),
                      ),
                      SizedBox(height: 8),
                      _DetailRow(
                        label: 'Monthly Payment',
                        value: '${debt.getMonthlyPayment().toStringAsFixed(2)} $preferedAmount',
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Helper widgets remain the same
class _DetailCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _DetailCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: valueColor ?? Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }
}