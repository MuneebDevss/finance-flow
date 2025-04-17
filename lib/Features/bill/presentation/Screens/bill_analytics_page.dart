import 'package:finance/Features/bill/presentation/controllers/bill_analytics_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class BillAnalyticsPage extends StatefulWidget {
  BillAnalyticsPage({super.key});

  @override
  State<BillAnalyticsPage> createState() => _BillAnalyticsPageState();
}

class _BillAnalyticsPageState extends State<BillAnalyticsPage> {
  final BillAnalyticsController controller = Get.put(BillAnalyticsController());

  late NumberFormat currencyFormat;
  @override
  void initState() {
    currencyFormat =
        NumberFormat.currency(symbol: '${controller.preferedAmount} ');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Analytics'),
        actions: [
          PopupMenuButton<TimeRange>(
            icon: Icon(Icons.calendar_today),
            onSelected: controller.changeTimeRange,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: TimeRange.oneMonth,
                child: Text('Last Month'),
              ),
              PopupMenuItem(
                value: TimeRange.threeMonths,
                child: Text('Last 3 Months'),
              ),
              PopupMenuItem(
                value: TimeRange.sixMonths,
                child: Text('Last 6 Months'),
              ),
              PopupMenuItem(
                value: TimeRange.oneYear,
                child: Text('Last Year'),
              ),
            ],
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildTimeRangeChip(),
                    SizedBox(width: 16),
                    _buildExpenseSummary(),
                  ],
                ),
                SizedBox(height: 24),
                _buildCategoryBreakdown(),
                SizedBox(height: 24),
                _buildMonthlyTrend(),
                SizedBox(height: 24),
                _buildQuarterlyComparison(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTimeRangeChip() {
    String rangeText;
    switch (controller.selectedTimeRange.value) {
      case TimeRange.oneMonth:
        rangeText = 'Last Month';
        break;
      case TimeRange.threeMonths:
        rangeText = 'Last 3 Months';
        break;
      case TimeRange.sixMonths:
        rangeText = 'Last 6 Months';
        break;
      case TimeRange.oneYear:
        rangeText = 'Last Year';
        break;
      default:
        rangeText = 'Last 3 Months';
    }

    return Chip(
      label: Text(rangeText),
      avatar: Icon(Icons.date_range, size: 16),
    );
  }

  Widget _buildExpenseSummary() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Bill',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            currencyFormat.format(controller.totalExpenses),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBreakdown() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Expense Categories',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (controller.categoryExpenses.isEmpty)
              Center(child: Text('No expense data available'))
            else
              Column(
                children: [
                  SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: _buildPieChartSections(),
                        centerSpaceRadius: 40,
                        sectionsSpace: 2,
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildCategoryLegend(),
                ],
              ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _buildPieChartSections() {
    List<PieChartSectionData> sections = [];

    controller.categoryExpenses.forEach((category, amount) {
      final double percentage = controller.getCategoryPercentage(category);
      final Color color = controller.getCategoryColor(category);

      sections.add(
        PieChartSectionData(
          color: color,
          value: amount,
          title: '${percentage.toStringAsFixed(1)}%',
          radius: 80,
          titleStyle: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      );
    });

    return sections;
  }

  Widget _buildCategoryLegend() {
    return Column(
      children: controller.categoryExpenses.entries.map((entry) {
        final category = entry.key;
        final amount = entry.value;
        final percentage = controller.getCategoryPercentage(category);
        final color = controller.getCategoryColor(category);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  category,
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey[600]),
              ),
              SizedBox(width: 8),
              Text(
                currencyFormat.format(amount),
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Updated monthly trend chart with correct SideTitles implementation
  Widget _buildMonthlyTrend() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monthly Expenses',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (controller.monthlyExpenses.isEmpty)
              Center(child: Text('No monthly data available'))
            else
              SizedBox(
                height: 250,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxMonthlyAmount() * 1.2,
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            currencyFormat.format(rod.toY),
                            TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                currencyFormat.format(value).split('.')[0],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            // We'll show only some months to avoid crowding
                            final index = value.toInt();
                            if (index % 2 == 0 &&
                                index < controller.monthlyExpenses.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  controller.monthlyExpenses[index]['month']
                                      .toString()
                                      .split(' ')[0],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 10,
                                  ),
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _buildMonthlyBarGroups(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

// Updated quarterly comparison chart with correct SideTitles implementation
  Widget _buildQuarterlyComparison() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Quarterly Comparison',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            if (controller.quarterlyExpenses.isEmpty)
              Center(child: Text('No quarterly data available'))
            else
              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(show: true),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Text(
                                currencyFormat.format(value).split('.')[0],
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 10,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final index = value.toInt();
                            if (index >= 0 &&
                                index < controller.quarterlyExpenses.length) {
                              return Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 8),
                                child: Text(
                                  controller.quarterlyExpenses[index]['label'],
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 5,
                                  ),
                                ),
                              );
                            }
                            return SizedBox.shrink();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: List.generate(
                            controller.quarterlyExpenses.length, (index) {
                          return FlSpot(
                            index.toDouble(),
                            controller.quarterlyExpenses[index]['amount'],
                          );
                        }),
                        isCurved: true,
                        color: Colors.green,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.green.withOpacity(0.2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxMonthlyAmount() {
    double max = 0;
    for (var month in controller.monthlyExpenses) {
      if (month['amount'] > max) {
        max = month['amount'];
      }
    }
    return max;
  }

  List<BarChartGroupData> _buildMonthlyBarGroups() {
    return List.generate(controller.monthlyExpenses.length, (index) {
      final data = controller.monthlyExpenses[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: data['amount'],
            color: Colors.blue,
            width: 16,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }
}
