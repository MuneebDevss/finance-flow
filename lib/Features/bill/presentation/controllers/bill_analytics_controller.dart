import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BillAnalyticsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable data for analytics
  final RxMap<String, double> categoryExpenses = <String, double>{}.obs;
  final RxList<Map<String, dynamic>> monthlyExpenses =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> quarterlyExpenses =
      <Map<String, dynamic>>[].obs;

  // Loading state
  final RxBool isLoading = false.obs;
  void fetchPreferedAmount() async {
    try {
      isLoading.value = true;
      final user = await _usersRepository.fetchCurrentUser();
      preferedAmount = user.preferedCurrency;
      isLoading.value = false;
    } on Exception {}
  }

  String preferedAmount = "";
  final UsersRepository _usersRepository = UsersRepository();

  // Time range selection
  final Rx<TimeRange> selectedTimeRange = TimeRange.threeMonths.obs;

  // Current user ID
  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchAnalyticsData();
    fetchPreferedAmount();
  }

  Future<void> fetchAnalyticsData() async {
    try {
      isLoading.value = true;

      await Future.wait([
        _fetchCategoryExpenses(),
        _fetchMonthlyExpenses(),
        _fetchQuarterlyExpenses(),
      ]);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load analytics data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchCategoryExpenses() async {
    // Reset the map
    categoryExpenses.clear();

    // Get date range based on selected time range
    final DateTimeRange dateRange = _getDateRange();

    // Get payment history within the date range
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_history')
        .where('paymentDate', isGreaterThanOrEqualTo: dateRange.start)
        .where('paymentDate', isLessThanOrEqualTo: dateRange.end)
        .get();

    // Get all bills to categorize them
    final billsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('bills')
        .get();

    // Create a map of bill IDs to their categories
    final Map<String, String> billCategories = {};
    for (var doc in billsSnapshot.docs) {
      final data = doc.data();
      final String billId = doc.id;
      // Assuming you add a 'category' field to your Bill model
      final String category = data['category'] ?? 'Other';
      billCategories[billId] = category;
    }

    // Calculate expenses by category
    for (var doc in snapshot.docs) {
      final paymentData = doc.data();
      final double amount = paymentData['amount'] ?? 0.0;
      final String billId = paymentData['billId'] ?? '';

      // Get category or default to 'Other'
      final String category = billCategories[billId] ?? 'Other';

      // Update category total
      categoryExpenses[category] = (categoryExpenses[category] ?? 0) + amount;
    }
  }

  Future<void> _fetchMonthlyExpenses() async {
    monthlyExpenses.clear();

    // Get date range - for monthly we'll look at the last 12 months
    final now = DateTime.now();
    final startDate = DateTime(now.year - 1, now.month + 1, 1);

    final months = <DateTime>[];
    for (int i = 0; i < 12; i++) {
      months.add(DateTime(startDate.year, startDate.month + i, 1));
    }

    // Get payment history
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_history')
        .where('paymentDate', isGreaterThanOrEqualTo: startDate)
        .orderBy('paymentDate')
        .get();

    // Group payments by month
    final Map<String, double> monthlyTotals = {};
    for (var doc in snapshot.docs) {
      final paymentData = doc.data();
      final DateTime paymentDate =
          (paymentData['paymentDate'] as Timestamp).toDate();
      final double amount = paymentData['amount'] ?? 0.0;

      // Format as YYYY-MM for grouping
      final String monthKey = DateFormat('yyyy-MM').format(paymentDate);
      monthlyTotals[monthKey] = (monthlyTotals[monthKey] ?? 0) + amount;
    }

    // Create a list of all months with their totals
    for (var month in months) {
      final String monthKey = DateFormat('yyyy-MM').format(month);
      final String monthLabel = DateFormat('MMM yyyy').format(month);

      monthlyExpenses.add({
        'month': monthLabel,
        'amount': monthlyTotals[monthKey] ?? 0.0,
      });
    }
  }

  Future<void> _fetchQuarterlyExpenses() async {
    quarterlyExpenses.clear();

    // Get date range - look at last 2 years by quarter
    final now = DateTime.now();
    final startDate = DateTime(now.year - 2, (now.month ~/ 3) * 3 + 1, 1);

    // Generate quarters
    final quarters = <Map<String, dynamic>>[];
    for (int i = 0; i < 8; i++) {
      final int year = startDate.year + (i ~/ 4);
      final int quarterNum = (startDate.month ~/ 3) + (i % 4) + 1;
      final int startMonth = ((quarterNum - 1) % 4) * 3 + 1;

      final startOfQuarter = DateTime(year, startMonth, 1);
      final endOfQuarter = DateTime(
        startMonth == 10 ? year + 1 : year,
        startMonth == 10 ? 1 : startMonth + 3,
        1,
      ).subtract(Duration(days: 1));

      quarters.add({
        'label': 'Q$quarterNum ${year}',
        'start': startOfQuarter,
        'end': endOfQuarter,
        'amount': 0.0,
      });
    }

    // Get payment history
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('payment_history')
        .where('paymentDate', isGreaterThanOrEqualTo: startDate)
        .orderBy('paymentDate')
        .get();

    // Calculate quarterly totals
    for (var doc in snapshot.docs) {
      final paymentData = doc.data();
      final DateTime paymentDate =
          (paymentData['paymentDate'] as Timestamp).toDate();
      final double amount = paymentData['amount'] ?? 0.0;

      // Find which quarter this payment belongs to
      for (var quarter in quarters) {
        if (paymentDate.isAfter(quarter['start']) &&
            paymentDate.isBefore(quarter['end'])) {
          quarter['amount'] += amount;
          break;
        }
      }
    }

    // Update the observable list
    quarterlyExpenses.assignAll(quarters);
  }

  DateTimeRange _getDateRange() {
    final now = DateTime.now();
    DateTime start;

    switch (selectedTimeRange.value) {
      case TimeRange.oneMonth:
        start = DateTime(now.year, now.month - 1, now.day);
        break;
      case TimeRange.threeMonths:
        start = DateTime(now.year, now.month - 3, now.day);
        break;
      case TimeRange.sixMonths:
        start = DateTime(now.year, now.month - 6, now.day);
        break;
      case TimeRange.oneYear:
        start = DateTime(now.year - 1, now.month, now.day);
        break;
      default:
        start = DateTime(now.year, now.month - 3, now.day);
    }

    return DateTimeRange(start: start, end: now);
  }

  void changeTimeRange(TimeRange range) {
    selectedTimeRange.value = range;
    fetchAnalyticsData();
  }

  // Helper function to get total expenses for the selected period
  double get totalExpenses {
    double total = 0;
    categoryExpenses.forEach((_, value) {
      total += value;
    });
    return total;
  }

  // Function to get category percentage
  double getCategoryPercentage(String category) {
    if (totalExpenses == 0) return 0;
    return (categoryExpenses[category] ?? 0) / totalExpenses * 100;
  }

  // Function to get category colors
  Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'loan':
        return Colors.blue;
      case 'utility':
        return Colors.green;
      case 'credit':
        return Colors.orange;
      case 'rent':
        return Colors.red;
      case 'insurance':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}

enum TimeRange {
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
}
