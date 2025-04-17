import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/SavingGoals/Domain/saving_goal_entity.dart';
import 'package:finance/Features/SavingGoals/Presentation/GoalsControllers/saving_goals_controller.dart';
import 'package:finance/Features/SavingGoals/Presentation/Screens/add_goal.dart';
import 'package:finance/Features/SavingGoals/Presentation/Widgets/empty_goals_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavingsPage extends GetView<SavingsController> {
  @override
  Widget build(BuildContext context) {
    Get.put(SavingsController());
    
    return RefreshIndicator(
      onRefresh: () =>controller.refreshGoals(),
      child: Scaffold(
        bottomNavigationBar: bottomNavigationWidget(controller.selected),
        appBar: AppBar(
          leading: Icon(Icons.savings_outlined),
          elevation: 0,
          title: Text(
            'Savings Goals',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: IconButton(
                icon: Icon(Icons.add_circle_outline),
                onPressed: () => Get.to(()=>AddGoalPage()),
              ),
            ),
          ],
        ),
        body: Container(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: Obx(() {
      if (controller.isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      return Column(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(context),
                const SizedBox(height: 16),
                
                // Show Savings Overview only when target is reached
                if ((controller.totalTarget - controller.totalSaved) == 0.0)
                  Expanded(
                    child: SavingsOverviewScreen(
                      preferedAmount: controller.preferedAmount,
                    ),
                  ),
                
                Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    "Saving Goals",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Goals List Section
                if (controller.goals.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: controller.goals.length,
                      itemBuilder: (context, index) {
                        final goal = controller.goals[index];
                        final progress = goal.targetAmount == 0.0
                            ? 0.0
                            : goal.savedAmount / goal.targetAmount;
                        final progressColor = _getProgressColor(progress);
                        final isAffected = controller.affectedGoals.contains(goal.id);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF31363F),
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
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {},
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Text(
                                                      "Goal:",
                                                      style: Theme.of(context).textTheme.titleMedium,
                                                    ),
                                                    SizedBox(width: Sizes.sm),
                                                    Text(
                                                      goal.name,
                                                      style: Theme.of(context).textTheme.titleMedium,
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: Sizes.spaceBtwItems),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.category_outlined, color: Colors.blue),
                                                    SizedBox(width: Sizes.sm),
                                                    Text(
                                                      goal.category,
                                                      style: Theme.of(context).textTheme.bodyLarge,
                                                    ),
                                                  ],
                                                ),
                                                if (isAffected) ...[
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: const [
                                                      Icon(
                                                        Icons.warning_amber_rounded,
                                                        color: Colors.red,
                                                        size: 16,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        'At risk due to overspending',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                          fontSize: 12,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          _buildPopupMenu(context, goal),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: progress.clamp(0.0, 1.0),
                                          backgroundColor: HelpingFunctions.isDarkMode(context)
                                              ? Colors.grey.shade200
                                              : Colors.grey,
                                          valueColor: AlwaysStoppedAnimation(progressColor),
                                          minHeight: 8,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${goal.savedAmount.toStringAsFixed(2)} ${controller.preferedAmount}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          Text(
                                            '${goal.targetAmount.toStringAsFixed(2)} ${controller.preferedAmount}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      );
    }),
  ),
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context) {
    return Obx(() => Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Total Saved',
                  controller.totalSaved.toStringAsFixed(2),
                  controller.preferedAmount,
                  Icons.savings,
                  Colors.green,
                  Color(0xFF006A67),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildSummaryCard(
                  context,
                  'Remaining',
                  (controller.totalTarget - controller.totalSaved).toStringAsFixed(2),
                  controller.preferedAmount,
                  Icons.trending_up,
                  Color(0xFF430A5D),
                  Color(0xFFC63C51)
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          LinearProgressIndicator(
            value: controller.totalTarget == 0 ? 0 : 
                   (controller.totalSaved / controller.totalTarget).clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(Colors.green),
            minHeight: 8,
          ),
        ],
      ),
    ));
  }

  Widget _buildSummaryCard(BuildContext context, String title, String amount, 
                          String currency, IconData icon, Color color,Color backgroundColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              SizedBox(width: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '$currency $amount',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context, SavingsGoal goal) {
  return PopupMenuButton<String>(
    icon: const Icon(Icons.more_vert, color: Colors.black),
    onSelected: (value) async {
      if (value == 'add') {
        _showAddFundsDialog(context, goal);
      } else if (value == 'delete') {
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Savings Goal'),
            content: Text('Are you sure you want to delete "${goal.name}"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'DELETE',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldDelete == true) {
          try {
            await controller.deleteSavingsGoal(goal.id);
            Get.snackbar(
              'Success',
              'Savings goal deleted successfully',
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to delete savings goal',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        }
      }
    },
    itemBuilder: (context) => [
      const PopupMenuItem(
        value: 'add',
        child: Row(
          children: [
            Icon(Icons.add_circle_outline),
            SizedBox(width: 8),
            Text('Add Funds'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete_outline, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Goal', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ],
  );
}
  Color _getProgressColor(double progress) {
    if (progress >= 0.9) return Colors.green;
    if (progress >= 0.6) return Colors.yellow;
    return Colors.red;
  }

  

  Future<void> _showAddFundsDialog(BuildContext context, SavingsGoal goal) async {
    final amountController = TextEditingController();

    await Get.dialog(
      AlertDialog(
        title: Text('Add Funds'),
        content: TextField(
          controller: amountController,
          decoration: InputDecoration(labelText: 'Amount'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (amountController.text.isNotEmpty) {
                final amount = double.parse(amountController.text);
                if (amount > 0) {
                  controller.addFunds(goal.id, amount);
                  Get.back();
                }
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }
  
}
