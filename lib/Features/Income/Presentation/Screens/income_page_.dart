import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Income/Presentation/Controllers/income_controller.dart';
import 'package:finance/Features/Income/Presentation/Screens/add_edit_income.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_categories.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_statistics.dart';
import 'package:finance/Features/Income/Presentation/Widgets/avatar.dart';
import 'package:finance/Features/zakat/Presentation/Screens/asset_management_page.dart';
import 'package:finance/Features/zakat/Presentation/Screens/zakat_history_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class IncomeListPage extends StatefulWidget {
  const IncomeListPage({super.key});

  @override
  State<IncomeListPage> createState() => _IncomeListPageState();
}

class _IncomeListPageState extends State<IncomeListPage>
    with SingleTickerProviderStateMixin {
  final IncomeController controller = Get.put(IncomeController());
  @override
  void initState() {
    controller.fetchIncomeEntries();
    controller.fetchCategories();
    controller.fetchPreferedAmount();
    controller.getTotalExpenses();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to AddIncomePage with a smooth transition
          Get.to(() => AddIncomePage(),
              transition: Transition.circularReveal,
              duration: Duration(milliseconds: 700));
        }, // Add an icon with size adjustment
        backgroundColor: Colors.blue,
        tooltip: 'Add Income',
        child: Icon(Icons.add, size: 30),
      ),
      bottomNavigationBar: bottomNavigationWidget(controller.selected),
      body: _buildIncomeList(),
    );
  }

  // Tab 1: Income List
  Widget _buildIncomeList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final totalIncome = controller.incomeEntries.fold<double>(
        0,
        (sum, entry) =>
            sum + (entry['amount'] > 0 ? entry['amount'] as double : 0),
      );

      // Get unique categories for filter
      final categories = controller.incomeEntries
          .map((entry) => entry['category'] as String)
          .toSet()
          .toList();

      // Filter entries based on selected category
      final filteredEntries = controller.selectedCategory.value.isEmpty
          ? controller.incomeEntries
          : controller.incomeEntries
              .where((entry) =>
                  entry['category'] == controller.selectedCategory.value)
              .toList();

      return Column(
        children: [
          SizedBox(
            height: Sizes.appBarHeight,
          ),
          // Balance Card
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SelectableAvatar(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ' Hi, Welcome',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              ' ${controller.currentUsersName}',
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: Sizes.spaceBtwSections),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "My Balance: ",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          SizedBox(
                            height: Sizes.sm,
                          ),
                          Row(
                            children: [
                              Text(
                                "${controller.incomeEntries.fold<double>(
                                      0,
                                      (sum, entry) =>
                                          sum + (entry['amount'] as double),
                                    ).toStringAsFixed(0)} ",
                                style:
                                    Theme.of(context).textTheme.headlineLarge,
                              ),
                              Text(
                                controller.preferedAmount,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            // Navigate to Analytics tab
                            Get.to(() => ChartPage());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(
                                    Sizes.borderRadiusXlg),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.7),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                  ),
                                ]),
                            child: Row(
                              children: [
                                Icon(Icons.analytics_outlined),
                                SizedBox(width: Sizes.sm),
                                Text('Statistics'),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: Sizes.spaceBtwSections),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => IncomeCategoriesPage());
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius:
                                  BorderRadius.circular(Sizes.borderRadiusXlg),
                            ),
                            child: Row(
                              children: [
                                Text('Categories'),
                                SizedBox(width: Sizes.sm),
                                Icon(Iconsax.arrow_down_1),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.arrow_upward,
                        title: 'Income',
                        amount: totalIncome,
                        color: Color(0xFF006A67),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        icon: Icons.arrow_downward,
                        title: 'Expense',
                        amount: controller.totalExpense.value,
                        color: Color(0xFFC63C51),
                      ),
                    ),
                  ],
                ),

                // Assets and Zakat Buttons Row - ADDED HERE
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => AssetManagementPage()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF49243E),
                            borderRadius:
                                BorderRadius.circular(Sizes.borderRadiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.account_balance_wallet,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Assets',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.to(() => ZakatHistoryPage()),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006A67),
                            borderRadius:
                                BorderRadius.circular(Sizes.borderRadiusLg),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                spreadRadius: 0,
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.volunteer_activism,
                                  color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Zakat',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Category Filter and Transactions Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Incomes',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.filter_list),
                  onSelected: (String category) {
                    controller.selectedCategory.value =
                        category == 'All' ? '' : category;
                  },
                  itemBuilder: (BuildContext context) => [
                    const PopupMenuItem<String>(
                      value: 'All',
                      child: Text('All Categories'),
                    ),
                    ...categories.map((category) => PopupMenuItem<String>(
                          value: category,
                          child: Text(category),
                        )),
                  ],
                ),
              ],
            ),
          ),

          if (filteredEntries.isEmpty)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No income',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                itemCount: filteredEntries.length,
                itemBuilder: (context, index) {
                  final income = filteredEntries[index];
                  final category = income['category'] as String;
                  final iconData = _getCategoryIcon(category);
                  final color = _getCategoryColor(category);

                  return Dismissible(
                    key: Key(income['id'].toString()),
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.red[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.white,
                      ),
                    ),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      _confirmDelete(context, income['id']);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Color(0xFF49243E),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(iconData, color: Colors.white),
                        ),
                        title: Text(
                          income['sourceName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              (income['dateReceived'] as Timestamp)
                                  .toDate()
                                  .toIso8601String()
                                  .substring(0, 10),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                            Text(
                              category,
                              style: TextStyle(
                                color: color,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '${income['amount'] >= 0 ? "+" : ""} ${income['amount'].toStringAsFixed(2)} ${controller.preferedAmount}',
                          style: TextStyle(
                            color: income['amount'] >= 0
                                ? Colors.green[600]
                                : Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () => _navigateToEditIncome(income),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      );
    });
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required double amount,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${amount.toStringAsFixed(2)} ${controller.preferedAmount}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Colors.blue;
      case 'freelance':
        return Colors.purple;
      case 'investment':
        return Colors.green;
      case 'subscription':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'salary':
        return Icons.work;
      case 'freelance':
        return Icons.computer;
      case 'investment':
        return Icons.trending_up;
      case 'subscription':
        return Icons.subscriptions;
      default:
        return Icons.attach_money;
    }
  }

  void _confirmDelete(BuildContext context, String id) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this income entry?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () async {
                controller.fetchIncomeEntries();
                Navigator.pop(context);
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                controller.deleteIncomeEntry(id);
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditIncome(Map<String, dynamic> income) {
    controller.sourceNameController.text = income['sourceName'];
    controller.amountController.text = income['amount'].toString();
    controller.notesController.text = income['notes'] ?? '';
    controller.selectedCategory.value = income['category'];
    controller.selectedDate.value =
        (income['dateReceived'] as Timestamp).toDate();

    Get.to(() => AddIncomePage(
          incomeId: income['id'],
        ));
  }

  // Tab 2: Charts
}
