import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final String currencySymbol;
  final bool showTrend;
  final double? trendPercentage;
  final bool isPositiveTrend;
  final VoidCallback? onTap;

  const StatCard({
    super.key,
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.currencySymbol,
    this.showTrend = false,
    this.trendPercentage,
    this.isPositiveTrend = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        title,
                        style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (showTrend && trendPercentage != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isPositiveTrend
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPositiveTrend
                                ? Icons.arrow_upward
                                : Icons.arrow_downward,
                            color: isPositiveTrend ? Colors.green : Colors.red,
                            size: 12,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${trendPercentage!.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: isPositiveTrend ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  '$currencySymbol ${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: color,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Example usage:
class BudgetStatsRow extends StatelessWidget {
  final double totalSpent;
  final double remainingBudget;
  final String preferedAmount;
  final double? spentTrendPercentage;
  final bool isSpentTrendPositive;

  const BudgetStatsRow({
    super.key,
    required this.totalSpent,
    required this.remainingBudget,
    required this.preferedAmount,
    this.spentTrendPercentage,
    this.isSpentTrendPositive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            title: 'Spent',
            amount: totalSpent,
            icon: Icons.shopping_cart,
            color: Theme.of(context).primaryColor,
            currencySymbol: preferedAmount,
            showTrend: spentTrendPercentage != null,
            trendPercentage: spentTrendPercentage,
            isPositiveTrend: isSpentTrendPositive,
            onTap: () {
              // Handle tap on spent card
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            title: 'Remaining',
            amount: remainingBudget,
            icon: Icons.account_balance_wallet,
            color: remainingBudget < 0 ? Colors.red : Colors.green,
            currencySymbol: preferedAmount,
            onTap: () {
              // Handle tap on remaining card
            },
          ),
        ),
      ],
    );
  }
}