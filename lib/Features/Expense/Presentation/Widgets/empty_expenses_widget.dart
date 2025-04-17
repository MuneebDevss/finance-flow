import 'package:finance/Features/Expense/Domain/expense_repo.dart';
import 'package:finance/Features/Expense/Presentation/Controllers/expense_controller.dart';
import 'package:finance/Features/Expense/Presentation/Screens/add_expense.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ExpensesOverviewScreen extends StatelessWidget {
  
  final controller = Get.put(ExpenseController(ExpenseRepository()));

   ExpensesOverviewScreen({super.key});
   

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16),
                Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Container(
                    padding: EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).primaryColor.withOpacity(0.05),
                          Theme.of(context).cardColor,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.red.withOpacity(0.1),
                                Colors.orange.withOpacity(0.2),
                              ],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.2),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.red.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: Offset(0, 5),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                size: 48,
                                color: Colors.red[600],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32),
                        Text(
                          'Track Your Expenses',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 16),
                        Container(
                          constraints: BoxConstraints(maxWidth: 320),
                          child: Text(
                            'Monitor your spending habits and stay within your budget by tracking your daily expenses.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.6,
                              letterSpacing: 0.2,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ),
                        SizedBox(height: 32),
                        Container(
                          width: double.infinity,
                          constraints: BoxConstraints(maxWidth: 280),
                          child: Column(
                            children: [
                              ElevatedButton(
                                onPressed: () => Get.to(()=>AddExpenseScreen()),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                                  backgroundColor: Colors.red[600],
                                  foregroundColor: Colors.white,
                                  elevation: 8,
                                  shadowColor: Colors.red.withOpacity(0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add_circle_outline, size: 20),
                                    SizedBox(width: 12),
                                    Text(
                                      'Add New Expense',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
}