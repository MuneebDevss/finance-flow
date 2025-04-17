import 'package:finance/Features/Income/Presentation/Controllers/income_controller.dart';
import 'package:finance/Features/Income/Presentation/Widgets/income_line_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {
  
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
    return buildCharts();
  }
  Widget buildCharts() {
    return Obx(() {
      if (controller.incomeEntries.isEmpty) {
        return Center(
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
                'No incomes',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
        );
      }

      return // In your widget
Scaffold(
  appBar: AppBar(title: Text("Income Statistics"),),
  body: ListView(
    children: [
      
      IncomeTrendLineChart(incomeEntries: controller.incomeEntries),
      const SizedBox(height: 16),
      IncomeCategoryPieChart(incomeEntries: controller.incomeEntries),
      const SizedBox(height: 16),
      IncomeMonthlyBarChart(incomeEntries: controller.incomeEntries),
      const SizedBox(height: 16),
    ],),
);
    });
  }
}
