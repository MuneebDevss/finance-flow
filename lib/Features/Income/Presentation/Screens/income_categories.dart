import 'package:finance/Features/Income/Presentation/Controllers/income_category_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomeCategoriesPage extends StatelessWidget {
  final IncomeCategoriesController controller =
      Get.put(IncomeCategoriesController());

   IncomeCategoriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Income Categories"),
        
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Add Category
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.categoryNameController,
                    decoration: const InputDecoration(
                      labelText: "Category Name",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Obx(() {
                  return controller.isLoading.value
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () {
                            controller.addCategory(
                                controller.categoryNameController.text.trim());
                          },
                          child: const Text("Add"),
                        );
                }),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Categories:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Category List
            Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.categories.isEmpty) {
                return const Center(child: Text("No categories available."));
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: controller.categories.length,
                  itemBuilder: (context, index) {
                    final category = controller.categories[index];
                    return ListTile(
                      title: Text(category['name']),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Get.defaultDialog(
                                title: "Update Category",
                                content: TextField(
                                  controller: TextEditingController()
                                    ..text = category['name'],
                                  onChanged: (value) =>
                                      controller.categoryNameController.text =
                                          value,
                                  decoration: const InputDecoration(
                                    labelText: "Category Name",
                                  ),
                                ),
                                confirm: ElevatedButton(
                                  onPressed: () {
                                    controller.updateCategory(
                                      category['id'],
                                      controller.categoryNameController.text
                                          .trim(),
                                    );
                                    Get.back();
                                  },
                                  child: const Text("Update"),
                                ),
                                cancel: ElevatedButton(
                                  onPressed: Get.back,
                                  child: const Text("Cancel"),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              controller.deleteCategory(category['id']);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
