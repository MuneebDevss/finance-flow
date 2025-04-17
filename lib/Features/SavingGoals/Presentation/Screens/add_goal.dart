import 'package:finance/Features/SavingGoals/Presentation/GoalsControllers/saving_goals_controller.dart';
import 'package:finance/Features/SavingGoals/Presentation/Screens/saving_goals_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AddGoalPage extends StatefulWidget {
  const AddGoalPage({super.key});

  @override
  State<AddGoalPage> createState() => _AddGoalPageState();
}

class _AddGoalPageState extends State<AddGoalPage> {
  final controller=Get.find<SavingsController>();
  final nameController = TextEditingController();
  final amountController = TextEditingController();
  final categoryController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  DateTime? selectedDeadline;

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    categoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Goal'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Goal Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a goal name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: amountController,
                  decoration: const InputDecoration(
                    labelText: 'Target Amount',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter target amount';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Please enter a valid number';
                    }
                    if (double.parse(value) <= 0) {
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
                  items: controller.allCategories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (value) {
                    categoryController.text = value ?? '';
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please select a category';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      setState(() {
                        selectedDeadline = picked;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today),
                        const SizedBox(width: 12),
                        Text(
                          selectedDeadline != null 
                            ? DateFormat('MMM dd, yyyy').format(selectedDeadline!)
                            : 'Select Deadline (Optional)',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),


// Replace the button with this
Obx(() => ElevatedButton(
  onPressed: controller.isLoading 
    ? null 
    : () async {
        if (formKey.currentState?.validate() ?? false) {
          try {
            
            await controller.createGoal(
              nameController.text.trim(),
              double.parse(amountController.text),
              selectedDeadline,
              categoryController.text.trim(),
            );
            Get.off(() => SavingsPage());
          } catch (e) {
            Get.snackbar(
              'Error',
              'Failed to create goal: ${e.toString()}',
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          } 
        }
      },
  style: ElevatedButton.styleFrom(
    padding: const EdgeInsets.symmetric(vertical: 15),
  ),
  child: controller.isLoading
    ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
    : const Text('Save Goal'),
)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}