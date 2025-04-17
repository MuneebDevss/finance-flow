
import 'package:finance/Features/BudgetPlanning/Domain/budget_entity.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Controllers/budget_controller.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_list_page.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_planner_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddBudgetScreen extends StatefulWidget {
  final Budget? budget;
  const AddBudgetScreen({super.key, this.budget});

  @override
  State<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends State<AddBudgetScreen> {
  final budgetController = Get.put(BudgetController());
  final formKey = GlobalKey<FormState>();
  final categoryController = TextEditingController();
  final amountController = TextEditingController();

  final List<String> predefinedCategories = [
    'Groceries', 'Rent', 'Utilities', 'Fitness'
  ];

  bool get isEditing => widget.budget != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      categoryController.text = widget.budget!.category;
      amountController.text = widget.budget!.amount.toString();
    }
  }

  @override
  void dispose() {
    categoryController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (formKey.currentState?.validate() ?? false) {
      final amount = double.parse(amountController.text);
      final category = categoryController.text;

      if (isEditing) {
        budgetController.updateBudget(
          category,
          amount,
          widget.budget!.date,
        );
        Get.offAll(() =>  BudgetListScreen());
      } else {
        budgetController.setBudget(
          category,
          amount,
        );
        Get.offAll(() => const BudgetDashboard());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Budget' : 'Add Budget'),
      ),
      body: FutureBuilder<void>(
        future: budgetController.fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> allCategories = [
            ...predefinedCategories,
            ...budgetController.categories,
          ];

          return Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      prefixText: '\$', // Add currency symbol
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter an amount';
                      }
                      final amount = double.tryParse(value!);
                      if (amount == null) {
                        return 'Please enter a valid number';
                      }
                      if (amount <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    value: categoryController.text.isNotEmpty ? categoryController.text : null,
                    items: allCategories.map((category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    )).toList(),
                    onChanged: (value) {
                      setState(() {
                        categoryController.text = value ?? '';
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: Text(
                        isEditing ? 'Update Budget' : 'Save Budget',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}