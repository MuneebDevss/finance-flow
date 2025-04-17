import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Expense/Domain/expense_entity.dart';
import 'package:finance/Features/Expense/Domain/expense_repo.dart';
import 'package:finance/Features/Expense/Presentation/Controllers/expense_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddExpenseScreen extends StatefulWidget {
  final Expense? expense;
  
  const AddExpenseScreen({super.key, this.expense});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final expenseController = Get.put(ExpenseController(ExpenseRepository()));
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final categoryController = TextEditingController();

  final List<String> predefinedCategories = [
    'Groceries', 'Rent', 'Utilities', 'Fitness'
  ];

  @override
  void initState() {
    super.initState();
    // Populate the form if expense is provided (edit mode)
    if (widget.expense != null) {
      nameController.text = widget.expense!.name;
      amountController.text = widget.expense!.amount.toString();
      categoryController.text = widget.expense!.category;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.expense != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Expense' : 'Add Expense'),
      ),
      body: FutureBuilder<void>(
        future: expenseController.fetchCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          List<String> allCategories = [
            ...predefinedCategories,
            ...expenseController.categories,
          ];

          return Form(
            key: formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(labelText: 'Expense Name'),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter expense name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),
                  TextFormField(
                    controller: amountController,
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter amount';
                      }
                      if (double.tryParse(value!) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: Sizes.spaceBtwItems),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Category'),
                    value: categoryController.text.isNotEmpty ? categoryController.text : null,
                    items: allCategories
                        .map((category) => DropdownMenuItem(
                              value: category,
                              child: Text(category),
                            ))
                        .toList(),
                    onChanged: (value) {
                      categoryController.text = value ?? '';
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a category';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(height: Sizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState?.validate() ?? false) {
                          if (isEditing) {
                            // Update existing expense
                            expenseController.updateExpense(
Expense(id: widget.expense!.id,name: nameController.text, amount: double.parse(amountController.text), category: categoryController.text, date: widget.expense!.date)
                            );
                            
                          } else {
                            // Add new expense
                            expenseController.addExpense(
                              nameController.text,
                              double.parse(amountController.text),
                              categoryController.text,
                            );
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: Text(isEditing ? 'Update' : 'Save'),
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

