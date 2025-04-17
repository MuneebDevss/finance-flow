

import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_entity.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_repos.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Controllers/budget_controller.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/add_budget.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_history.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_list_page.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/widgets/empty_budget_card.dart';
import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
class CategoryData {
  final double budget;
   double spent;
  
  CategoryData({required this.budget, required this.spent});
}

class BudgetDashboard extends StatefulWidget {
  const BudgetDashboard({super.key});

  @override
  State<BudgetDashboard> createState() => _BudgetDashboardState();
}

class _BudgetDashboardState extends State<BudgetDashboard> {
  final BudgetService _budgetService = BudgetService();
  final controller=Get.put(BudgetController());
  bool _isLoading = true;
  List<Budget> budgets=[];
  String? _error;
  Map<String, CategoryData> _categories = {};
  double _totalBudget = 0;
  double _totalSpent = 0;

  @override
  void initState() {
    super.initState();
    _loadBudgetData();
  }

  Future<void> _loadBudgetData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Load budgets and expenses
       budgets = await _budgetService.getAllBudgets();
      final expenses = await _budgetService.getCurrentMonthExpenses();
      
      // Calculate category totals
      final Map<String, CategoryData> categories = {};
      double totalBudget = 0;
      double totalSpent = 0;

      // Initialize categories with budgets
      for (var budget in budgets) {
        categories[budget.category] = CategoryData(
          budget: budget.amount,
          spent: 0,
        );
        totalBudget += budget.amount;
      }
      print(budgets.length);
      // Add expenses to categories
      for (var expense in expenses) {
        if (categories.containsKey(expense.category)) {
          final currentSpent = categories[expense.category]!.spent + expense.amount;
          categories[expense.category] = CategoryData(
            budget: categories[expense.category]!.budget,
            spent: currentSpent,
          );
          totalSpent += expense.amount;
        }
      }

      setState(() {
        _categories = categories;
        _totalBudget = totalBudget;
        _totalSpent = totalSpent;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load budget data: $e';
        _isLoading = false;
      });
    }
  }

  Color getColorByPercentage(double percentage) {
    if (percentage < 70) {
      return Colors.green;
    } else if (percentage < 90) {
      return Colors.orange;
    }
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        bottomNavigationBar: bottomNavigationWidget(controller.selected),
        appBar: AppBar(
          leading: Icon(Icons.trending_up_outlined),
          title: const Text('Budget Tracker'),
          backgroundColor: Colors.black,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: Colors.red[400], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadBudgetData,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077FF),
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final remainingBudget = _totalBudget - _totalSpent;
    final spentPercentage = (_totalBudget == 0.0) ? 0.0 : (_totalSpent / _totalBudget) * 100;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddBudgetScreen(), transition: Transition.fadeIn);
        },
        backgroundColor: const Color(0xFF0077FF),
        elevation: 4,
        child: const Icon(Icons.add, size: 30),
      ),
      appBar: AppBar(
        leading: Icon(Icons.trending_up_outlined),
        title: const Text('Budget Tracker', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'Manage Budgets') {
                Get.to(() => BudgetListScreen(), transition: Transition.fadeIn);
              } else if (value == 'Budget History') {
                Get.to(() => MonthlyBudgetPage(), transition: Transition.fadeIn);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'Manage Budgets',
                child: Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: Color(0xFF0077FF)),
                    SizedBox(width: 12),
                    Text('Manage Budgets'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'Budget History',
                child: Row(
                  children: [
                    Icon(Icons.history, color: Color(0xFF0077FF)),
                    SizedBox(width: 12),
                    Text('Budget History'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      bottomNavigationBar: bottomNavigationWidget(controller.selected),
      body: RefreshIndicator(
        onRefresh: _loadBudgetData,
        color: const Color(0xFF0077FF),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              Container(

                
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  
                  color: Colors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                         Text(
                          'Total Budget',
                          style: Theme.of(context).textTheme.headlineMedium  ,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_totalBudget.toStringAsFixed(2)} ${controller.preferedAmount}',
                            style: const TextStyle(
                              color: Color(0xFF0077FF),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              'Spent',
                              _totalSpent,
                              Icons.shopping_cart,
                              Color(0xFF006A67),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              'Remaining',
                              remainingBudget,
                              Icons.account_balance_wallet,
                              Color(0xFFC63C51),
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: _totalBudget == 0.0 ? 0.0 : _totalSpent / _totalBudget,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          getColorByPercentage(spentPercentage),
                        ),
                        minHeight: 20,
                      ),
                    ),
                    if (spentPercentage > 90) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red[100]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.red[400]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Warning: You\'re approaching your budget limit!',
                                style: TextStyle(color: Colors.red[400]),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if(_categories.entries.isNotEmpty)
                    const Text(
                      'Category Breakdown',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                     ..._categories.entries.map((category) {
                      final categoryPercentage = (category.value.spent / category.value.budget) * 100;
                      final categoryColor = _getCategoryColor(category.key);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Color(0xFF31363F),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [

                                    Icon(_getCategoryIcon(category.key), color: categoryColor),
                                    const SizedBox(width: 8),
                                    Text(
                                      category.key,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,

                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${(categoryPercentage).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: getColorByPercentage(categoryPercentage),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${category.value.spent.toStringAsFixed(2)} ${controller.preferedAmount}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  'of ${category.value.budget.toStringAsFixed(2)} ${controller.preferedAmount}',
                                  style: TextStyle(
                                    
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: LinearProgressIndicator(
                                value: category.value.budget == 0.0 ? 0.0 : category.value.spent / category.value.budget,
                                backgroundColor: categoryColor.withOpacity(0.1),
                                valueColor: AlwaysStoppedAnimation<Color>(categoryColor),
                                minHeight: 10,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    if(budgets.isEmpty)
                    BudgetOverviewScreen(preferedAmount: controller.preferedAmount,),
                    const SizedBox(height: 24),
                    if(budgets.isNotEmpty&&spentPercentage!=0)
                    const Text(
                      'Spending Distribution',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if(budgets.isNotEmpty&&spentPercentage!=0)
                    
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 250,
                          child: PieChart(
                            PieChartData(
                              sections: _createPieChartSections(),
                              sectionsSpace: 2,
                              centerSpaceRadius: 40,
                              borderData: FlBorderData(show: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


Widget _buildStatCard(String title, double amount, IconData icon, Color color) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          '${amount.toStringAsFixed(2)} ${controller.preferedAmount}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ],
    ),
  );
}

Color _getCategoryColor(String category) {
  switch (category.toLowerCase()) {
    case 'food':
      return Colors.orange;
    case 'transport':
      return Colors.blue;
    case 'entertainment':
      return Colors.purple;
    case 'shopping':
      return Colors.pink;
    case 'utilities':
      return Colors.teal;
    case 'health':
      return Colors.red;
    case 'education':
      return Colors.indigo;
    default:
      return Colors.blue;
  }
}

IconData _getCategoryIcon(String category) {
  switch (category.toLowerCase()) {
    case 'Food':
      return Icons.restaurant;
    case 'Transport':
      return Icons.directions_car;
    case 'Entertainment':
      return Icons.movie;
    case 'Shopping':
      return Icons.shopping_bag;
    case 'Utilities':
      return Icons.power;
    case 'Fitness':
      return Icons.local_hospital;
    case 'Education':
      return Icons.school;
    default:
      return Icons.category;
  }
}

  List<PieChartSectionData> _createPieChartSections() {
  final Map<String, Color> colorMap = {
    'Groceries': Colors.blue,
    'Rent': Colors.green,
    'Utilities': Colors.orange,
    'Entertainment': Colors.purple,
    'Miscellaneous': Colors.red,
  };

  return _categories.entries.map((entry) {
    final String categoryKey = entry.key;
    CategoryData category = entry.value;

    // Calculate percentage only if total spent is not zero
    final categoryPercentage = (_totalSpent == 0.0) ? 0.0 : (category.spent / _totalSpent) * 100;

    // Retrieve the color for the current category from the map (or a default color)
    Color categoryColor = colorMap[categoryKey] ?? Colors.pinkAccent; 

    return PieChartSectionData(
      value: category.spent,
      title: '$categoryKey\n${categoryPercentage.toStringAsFixed(1)}%',
      color: categoryColor,
      radius: 100,
      titleStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }).toList();
}


}



