import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:get/get.dart';

class IncomeTrendLineChart extends StatelessWidget {
  final RxList<Map<String, dynamic>> incomeEntries;

  const IncomeTrendLineChart({
    super.key,
    required this.incomeEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (incomeEntries.isEmpty) {
        return const Center(child: Text('No income data available'));
      }

      final Map<String, double> dailyTotals = {};
      
      for (var entry in incomeEntries) {
        final date = (entry['dateReceived'] as Timestamp).toDate();
        final amount = (entry['amount'] as num).toDouble();
        final dateStr = DateFormat('MMM d').format(date);
        dailyTotals[dateStr] = (dailyTotals[dateStr] ?? 0) + amount;
      }

      final List<FlSpot> spots = [];
      final sortedDates = dailyTotals.keys.toList()..sort();
      
      for (int i = 0; i < sortedDates.length; i++) {
        spots.add(FlSpot(i.toDouble(), dailyTotals[sortedDates[i]]!));
      }

      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income Trends Over Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: 1,
                      verticalInterval: 1,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      ),
                      getDrawingVerticalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      ),
                    ),
                    titlesData: FlTitlesData(
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: spots.length > 6 ? (spots.length / 6).ceil().toDouble() : 1,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < sortedDates.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Text(
                                    sortedDates[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\$${NumberFormat.compact().format(value)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    borderData: FlBorderData(show: false),
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(show: spots.length < 15),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ],
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        
                        getTooltipItems: (touchedSpots) {
                          return touchedSpots.map((spot) {
                            final date = sortedDates[spot.x.toInt()];
                            return LineTooltipItem(
                              '$date\n\$${NumberFormat.currency(symbol: '').format(spot.y)}',
                              const TextStyle(color: Colors.white),
                            );
                          }).toList();
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class IncomeCategoryPieChart extends StatelessWidget {
  final RxList<Map<String, dynamic>> incomeEntries;

  const IncomeCategoryPieChart({
    super.key,
    required this.incomeEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (incomeEntries.isEmpty) {
        return const Center(child: Text('No income data available'));
      }

      // Process data by category
      final Map<String, double> categoryTotals = {};
      for (var entry in incomeEntries) {
        final category = entry['category'] as String;
        final amount = (entry['amount'] as num).toDouble();
        categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
      }

      // Convert to list for pie chart
      final List<PieChartSectionData> sections = [];
      final colors = [
        Colors.blue,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.red,
        Colors.teal,
      ];

      int colorIndex = 0;
      final total = categoryTotals.values.reduce((a, b) => a + b);

      categoryTotals.forEach((category, amount) {
        final percentage = (amount / total * 100);
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex % colors.length],
            value: amount,
            title: '${percentage.toStringAsFixed(1)}%',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
        colorIndex++;
      });

      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Income by Category',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 300,
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: PieChart(
                        PieChartData(
                          sections: sections,
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...categoryTotals.entries.map((entry) {
                            final index = categoryTotals.keys.toList().indexOf(entry.key);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: colors[index % colors.length],
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      entry.key,
                                      style: const TextStyle(fontSize: 12),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class IncomeMonthlyBarChart extends StatelessWidget {
  final RxList<Map<String, dynamic>> incomeEntries;

  const IncomeMonthlyBarChart({
    super.key,
    required this.incomeEntries,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (incomeEntries.isEmpty) {
        return const Center(child: Text('No income data available'));
      }

      // Group data by month
      final Map<String, double> monthlyTotals = {};
      for (var entry in incomeEntries) {
        final date = (entry['dateReceived'] as Timestamp).toDate();
        final monthYear = DateFormat('MMM yyyy').format(date);
        final amount = (entry['amount'] as num).toDouble();
        monthlyTotals[monthYear] = (monthlyTotals[monthYear] ?? 0) + amount;
      }

      final sortedMonths = monthlyTotals.keys.toList()..sort();
      final maxY = monthlyTotals.values.reduce((a, b) => a > b ? a : b) * 1.2;

      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Monthly Income',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 340,
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          return BarTooltipItem(
                            '${sortedMonths[groupIndex]}\n\$${NumberFormat.currency(symbol: '').format(rod.toY)}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 80,
                          getTitlesWidget: (value, meta) {
                            if (value.toInt() >= 0 && value.toInt() < sortedMonths.length) {
                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: RotatedBox(
                                  quarterTurns: 1,
                                  child: Text(
                                    sortedMonths[value.toInt()],
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              '\$${NumberFormat.compact().format(value)}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            );
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    ),
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      horizontalInterval: maxY / 6,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.grey[300],
                        strokeWidth: 1,
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: List.generate(
                      sortedMonths.length,
                      (index) => BarChartGroupData(
                        x: index,
                        barRods: [
                          BarChartRodData(
                            toY: monthlyTotals[sortedMonths[index]]!,
                            color: Colors.blue,
                            width: 16,
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}