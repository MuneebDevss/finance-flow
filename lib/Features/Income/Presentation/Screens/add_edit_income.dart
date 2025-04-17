import 'package:finance/Features/Auth/Widgets/input_field.dart';
import 'package:finance/Features/Income/Presentation/Controllers/income_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class AddIncomePage extends StatelessWidget {
  final IncomeController controller = IncomeController();
  String? incomeId;
  // Predefined income categories with icons
  final List<Map<String, dynamic>> predefinedCategories = [
    {'name': 'Salary', 'icon': Icons.work},
    {'name': 'Freelancing', 'icon': Icons.computer},
    {'name': 'Investments', 'icon': Icons.trending_up},
    {'name': 'Business', 'icon': Icons.business},
    {'name': 'Rental', 'icon': Icons.home},
    {'name': 'Other', 'icon': Icons.more_horiz},
  ];

  AddIncomePage({super.key, this.incomeId});

  @override
  Widget build(BuildContext context) {
    // Set initial category if not already set
    if (controller.selectedCategory.value.isEmpty) {
      controller.selectedCategory.value = predefinedCategories[0]['name'];
    }

    return Scaffold(
      appBar: AppBar(
        title: incomeId == null
            ? const Text("Add Income")
            : const Text("Update Income"),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Selection
              Text(
                'Select Category',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),

              // Predefined Categories with Icons
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: predefinedCategories.length,
                  itemBuilder: (context, index) {
                    final category = predefinedCategories[index];
                    return Obx(() => Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: InkWell(
                            onTap: () {
                              controller.selectedCategory.value =
                                  category['name'];
                            },
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: controller.selectedCategory.value ==
                                            category['name']
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Icon(
                                    category['icon'],
                                    color: controller.selectedCategory.value ==
                                            category['name']
                                        ? Colors.white
                                        : Colors.grey.shade700,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  category['name'],
                                  style: TextStyle(
                                    color: controller.selectedCategory.value ==
                                            category['name']
                                        ? Theme.of(context).primaryColor
                                        : Colors.grey.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ));
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Additional Categories from Controller
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: controller.selectedCategory.value,
                        hint: const Text("Other Categories"),
                        onChanged: (value) {
                          if (value != null) {
                            controller.selectedCategory.value = value;
                          }
                        },
                        items: <dynamic>{
                          // Combine predefined and controller categories
                          ...predefinedCategories
                              .map((category) => category['name']),
                          ...controller.categories
                        }
                            .toList() // Using toSet() to remove duplicates
                            .map((category) => DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                ))
                            .toList(),
                      ),
                    )),
              ),

              const SizedBox(height: 24),

              // Amount Field
              InputField(
                label: "Amount",
                inputType: TextInputType.number,
                controller: controller.amountController,
              ),
              const SizedBox(height: 24),

              // Source Name Field
              _buildTextField(
                controller: controller.sourceNameController,
                label: "Income Source",
                icon: Icons.source,
              ),
              const SizedBox(height: 16),

              // Date Picker
              Obx(() => InkWell(
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate:
                            controller.selectedDate.value ?? DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null)
                        controller.selectedDate.value = picked;
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today,
                              color: Colors.grey.shade700),
                          const SizedBox(width: 12),
                          Text(
                            controller.selectedDate.value != null
                                ? DateFormat('MMM dd, yyyy')
                                    .format(controller.selectedDate.value!)
                                : "Select Date",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  )),
              const SizedBox(height: 16),

              // Notes Field
              _buildTextField(
                controller: controller.notesController,
                label: "Notes (Optional)",
                icon: Icons.note,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Add Button
              Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (incomeId != null) {
                                controller.updateIncomeEntry(incomeId!);
                                print("object");
                              } else {
                                controller.addIncomeEntry();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: Theme.of(context).primaryColor,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            )
                          : Text(incomeId == null
                              ? "Add Income"
                              : "Update Income"),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          icon: Icon(icon, color: Colors.grey.shade700),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
