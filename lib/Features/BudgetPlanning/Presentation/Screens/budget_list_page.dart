import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_entity.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Controllers/budget_controller.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/add_budget.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_planner_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BudgetListScreen extends StatelessWidget {
  final BudgetController budgetController = Get.put(BudgetController());

  BudgetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Allocated Budgets'),
        leading: IconButton(onPressed: ()=>Get.offAll(()=>BudgetDashboard()), icon: Icon(Icons.arrow_back)),
      ),
      body: FutureBuilder<void>(
        future: budgetController.fetchAllBudgets(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (budgetController.budgets.isEmpty) {
            return const Center(child: Text('No budgets allocated yet.'));
          }

          return Obx((){
            return  ListView.builder(
              itemCount: budgetController.budgets.length,
              itemBuilder: (context, index) {
                final budget = budgetController.budgets[index];
                return Padding(
                  padding: const EdgeInsets.all(Sizes.spaceBtwItems),
                  child: Card(
                    child: ListTile(
                      title: Text('${budget.category} - ${budget.amount.toStringAsFixed(2)}'),
                      subtitle: Text('Date: ${budget.date.toLocal().toIso8601String().substring(0,10)}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Edit button
                          IconButton(
                            icon: const Icon(Icons.edit,color: Colors.amber,),
                            onPressed: () {
                              _editBudget(context, budget);
                            },
                          ),
                          // Delete button
                          IconButton(
                            icon: const Icon(Icons.delete,color: Colors.red,),
                            onPressed: () {
                              _confirmDeleteBudget(context, budget.category);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            );
        });
        },
      ),
    );
  }

  // Edit Budget
  void _editBudget(BuildContext context, Budget budget) {
    Get.to(() => AddBudgetScreen(budget: budget,), );
  }

  // Confirm Delete Budget
  void _confirmDeleteBudget(BuildContext context, String budgetId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Budget'),
        content: const Text('Are you sure you want to delete this budget?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              budgetController.deleteBudget(budgetId);
              Navigator.of(ctx).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
