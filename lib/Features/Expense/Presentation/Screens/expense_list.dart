
import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Expense/Domain/expense_entity.dart';
import 'package:finance/Features/Expense/Domain/expense_repo.dart';
import 'package:finance/Features/Expense/Presentation/Screens/add_expense.dart';
import 'package:finance/Features/Expense/Presentation/Screens/expense_category_screen.dart';
import 'package:finance/Features/Expense/Presentation/Widgets/empty_expenses_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:finance/Features/Expense/Presentation/Controllers/expense_controller.dart';
class ExpenseListScreen extends StatelessWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ExpenseController(ExpenseRepository()));
    Future<void> fetchAllExpenses() async {
      
     controller.fetchPreferedAmount();
    await controller.fetchExpenses();
    await controller.fetchCategories();
    }
    return RefreshIndicator(
      onRefresh: ()=> fetchAllExpenses(),
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(Icons.account_balance_wallet_outlined),
          title: const Text('Expense Tracking'),
          actions: [
            IconButton(onPressed: ()=>Get.to(()=>ExpenseCategoriesPage()), icon: Icon(Icons.category,color: Colors.amberAccent,)),
            SizedBox(width: Sizes.spaceBtwItems,)
          ],
        ),
        bottomNavigationBar: bottomNavigationWidget(controller.selected),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
      
          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Header Cards
                  SizedBox(
                    height: 140,
                    child: Row(
                      children: [
                        // Total Expenses Card
                        Expanded(
                          flex: 2,
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF000B58), Colors.blue],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Expenses',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '${controller.totalExpenses.value.toStringAsFixed(2)} ${controller.preferedAmount}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                const Text(
                                  'This Month',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        // Add Expense Card
                        Expanded(
                          child: Card(
                            child: InkWell(
                              onTap: () => Get.to(() => AddExpenseScreen()),
                              borderRadius: BorderRadius.circular(12),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_circle_outline,
                                    color: Colors.blue,
                                    size: 32,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Add\nExpense',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      
                  const SizedBox(height: 24),
      
                  // Recent Expenses
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Expenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (controller.expenses.isEmpty)
                        Center(
                          child: ExpensesOverviewScreen(),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.expenses.length,
                            separatorBuilder: (context, index) => const Divider(),
                            itemBuilder: (context, index) {
                              final expense = controller.expenses[index];
                              return ModernExpenseListTile(expense: expense, preferedAmount: controller.preferedAmount,);
                            },
                          ),
                        ),
                    ],
                  ),
      
                  const SizedBox(height: 24),
                  if(controller.expenses.isNotEmpty)
                  // Category Breakdown
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Category Breakdown',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ...controller.categoryBreakdown.entries.map(
                          (entry) => CategoryProgressBar(
                            category: entry.key,
                            amount: entry.value,
                            totalExpenses: controller.totalExpenses.value, preferedAmount: controller.preferedAmount,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class ModernExpenseListTile extends StatelessWidget {
  final Expense expense;
  final String preferedAmount;
  const ModernExpenseListTile({required this.expense, required this.preferedAmount});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (context) => ExpenseActionsSheet(expense: expense),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.attach_money,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expense.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    expense.category,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              '${expense.amount.toStringAsFixed(2)} $preferedAmount',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.more_vert,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryProgressBar extends StatelessWidget {
  final String category;
  final double amount;
  final double totalExpenses;
  final String preferedAmount;
  const CategoryProgressBar({super.key, 
    required this.category,
    required this.amount,
    required this.totalExpenses, required this.preferedAmount,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalExpenses > 0 ? (amount / totalExpenses) : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                '${amount.toStringAsFixed(2)} $preferedAmount',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}

class ExpenseActionsSheet extends StatelessWidget {
  final Expense expense;
  final controller = Get.find<ExpenseController>();

  ExpenseActionsSheet({required this.expense});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit, color: Colors.blue),
            title: const Text('Edit'),
            onTap: () {
              Get.back();
              Get.to(() => AddExpenseScreen(expense: expense,), );
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: Colors.red),
            title: const Text('Delete'),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Expense'),
                  content: const Text(
                    'Are you sure you want to delete this expense? This action cannot be undone.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        controller.deleteExpense(expense.id!);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}