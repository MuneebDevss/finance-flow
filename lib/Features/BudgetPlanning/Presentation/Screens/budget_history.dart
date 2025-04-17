import 'package:finance/Features/BudgetPlanning/Presentation/Controllers/budget_history_controller.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

// budget_controller.dart


// monthly_budget_page.dart
class MonthlyBudgetPage extends GetView<BudgetHistoryController> {
  @override
  Widget build(BuildContext context) {
    Get.put(BudgetHistoryController());
    return Scaffold(
      appBar: AppBar(title: Text('Monthly Budget Report')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDateSelector(),
            SizedBox(height: 16),
            _buildBudgetList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Obx(() => Card(
      child: ListTile(
        title: Text('Select Month'),
        subtitle: Text(DateFormat('MMMM yyyy').format(controller.selectedDate)),
        trailing: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () async {
            final picked = await showMonthPicker(
              context: Get.context!,
              initialDate: controller.selectedDate,
            );
            if (picked != null) {
              controller.updateDate(picked);
            }
          },
        ),
      ),
    ));
  }

  Widget _buildBudgetList() {
    return Obx(() {
      if (controller.isLoading) {
        return Center(child: CircularProgressIndicator());
      }

      final report = controller.budgetReport;
      if (report == null) {
        return Center(child: Text('No data available'));
      }

      return Expanded(
        child: ListView.builder(
          itemCount: (report['budgets'] as List<Budget>).length,
          itemBuilder: (context, index) {
            final budget = (report['budgets'] as List<Budget>)[index];
            final expenses = (report['expenses'] as Map<String, double>)[budget.category] ?? 0.0;
            final progress =budget.amount==0.0?0.0: expenses / budget.amount;

            return Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      budget.category,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation(
                        progress > 1.0 ? Colors.red : Colors.green,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Budget:${budget.amount.toStringAsFixed(2)} ${controller.preferedAmount}'),
                        Text('Spent:${expenses.toStringAsFixed(2)} ${controller.preferedAmount}'),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }
}

// Add binding
class BudgetBinding extends Bindings {
  @override
  void dependencies() {
    ;
  }
}