import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_repos.dart';
import 'package:finance/Features/SavingGoals/Domain/goals_repo.dart';
import 'package:finance/Features/SavingGoals/Domain/saving_goal_entity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavingsController extends GetxController {
  final SavingsService _service = SavingsService();
  final BudgetService _budgetService = BudgetService();
  final _goals = <SavingsGoal>[].obs;
  int selected = 4;
  final _isLoading = false.obs;
  final _totalSaved = 0.0.obs;
  final _totalTarget = 0.0.obs;
  final UsersRepository _usersRepository = UsersRepository();

  String preferedAmount = "";

  List<SavingsGoal> get goals => _goals;
  bool get isLoading => _isLoading.value;
  double get totalSaved => _totalSaved.value;
  double get totalTarget => _totalTarget.value;
  final _isOverspending = false.obs;
  final _affectedGoals = <String>[].obs;

  // Add getters
  bool get isOverspending => _isOverspending.value;
  List<String> get affectedGoals => _affectedGoals;
  final RxList<String> categories = <String>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchGoals();
    fetchCategories();
    fetchPreferedAmount();
    monitorOverspending();
  }
  String get currentUserId => _auth.currentUser?.uid ?? '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<String> allCategories = [];
  Future<void> fetchCategories() async {
    try {
      
      final userId = currentUserId;
      if (userId.isEmpty) {
        Get.snackbar(
          "Error",
          "User not logged in",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final snapshot = await _firestore
          .collection('categories')
          .doc('expenseCategoriesDocs')
          .collection('items')
          .where('userId', isEqualTo: userId) // Filter by user ID
          .get();
          final List<String> predefinedCategories = [
    'Groceries', 'Rent', 'Utilities', 'Fitness'
  ];
      categories.value = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
          allCategories = [
            ...predefinedCategories,
            ...categories,
          ];
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch categories: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      
    }
  }
  Future<void> deleteSavingsGoal(String goalId) async {
    _isLoading.value=true;
    await _service.deleteSavingsGoal(goalId);
    await refreshGoals(); 
    _isLoading.value=false;// Refresh the goals list after deletion
  }

  // Assuming you have a method to refresh goals
  Future<void> refreshGoals() async {
    try {
      final goals = await _service.getSavingsGoals();
      this.goals.assignAll(goals);
    } catch (e) {
      print('Error refreshing goals: $e');
    }
  }
Future<void> monitorOverspending() async {
  try {
    _isLoading.value = true;
    final budgets = await _budgetService.fetchCurrentMonthBudgets();
    final expenses = await _budgetService.getCurrentMonthExpenses();
    print("budgets ${budgets.length}");
    print("expenses ${expenses.length}");

    Map<String, double> categoryExpenses = {};
    for (var expense in expenses) {
      categoryExpenses[expense.category] = (categoryExpenses[expense.category] ?? 0) + expense.amount;
      
    }

    bool overspending = false;
    Set<String> affected = {};

    // Iterate through each budget and compare with expenses
    for (var budget in budgets) {
      if(categoryExpenses[budget.category]==null) {
        continue;
      }
          print("budgets ${budget.category}");
          print("expenses ${categoryExpenses[budget.category]}");
      final spent = categoryExpenses[budget.category] ?? 0;
      print(spent);
      print(budget.amount);
      // Check if there's overspending
      if (spent > budget.amount) {
        overspending = true;
        print("object");
        // Mark goals affected by the overspending category
        _goals.where((goal) => goal.category.trim().toLowerCase() == budget.category.trim().toLowerCase())
             .forEach((goal) => affected.add(goal.id));
      }
    }

    _isOverspending.value = overspending;
    _affectedGoals.value = affected.toList();

    // Display warning if there's overspending


    _isLoading.value = false;
  } catch (e) {
    print('Error monitoring overspending: $e');
  }
}


  Future<void> fetchGoals() async {
    _isLoading.value = true;
    try {
      final goals = await _service.getSavingsGoals();
      _goals.value = goals;
      _calculateTotals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load savings goals');
    } finally {
    }
  }

  void _calculateTotals() {
    _totalSaved.value = _goals.fold(0, (sum, goal) => sum + goal.savedAmount);
    _totalTarget.value = _goals.fold(0, (sum, goal) => sum + goal.targetAmount);
  }

  Future<void> createGoal(String name, double targetAmount, DateTime? deadline, String category) async {
    try {
      _isLoading.value = true;
      
      if (name.isEmpty || targetAmount <= 0 || category.isEmpty) {
        throw Exception('Invalid input data');
      }

      await _service.createSavingsGoal(name, targetAmount, deadline, category);
      await fetchGoals();
      await monitorOverspending(); // Refresh overspending status after adding new goal
      
      Get.snackbar(
        'Success',
        'Savings goal created successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      throw Exception('Failed to create savings goal: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }

  void fetchPreferedAmount() async {
    try {
      _isLoading.value = true;
      final user = await _usersRepository.fetchCurrentUser();
      preferedAmount = user.preferedCurrency;
    } on Exception catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch Prefered amount: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> addFunds(String goalId, double amount) async {
    try {
      await _service.addFunds(goalId, amount);
      await fetchGoals();
    } catch (e) {
      Get.snackbar('Error', 'Failed to add funds');
    }
  }
}