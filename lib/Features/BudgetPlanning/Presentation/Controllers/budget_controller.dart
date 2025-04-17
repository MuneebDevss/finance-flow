import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_entity.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_repos.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BudgetController extends GetxController {
   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
     final RxBool isLoading = false.obs;
     final FirebaseAuth _auth = FirebaseAuth.instance;
     int selected=2;
    String get currentUserId => _auth.currentUser?.uid ?? '';
  final RxList<String> categories = <String>[].obs;
final BudgetService _budgetService = BudgetService();
  final UsersRepository _usersRepository = UsersRepository();
  
  String preferedAmount="";

@override
  void onInit() {
    super.onInit();

    fetchCategories();
        fetchPreferedAmount();

  }
  
  Future<void> deleteBudget(String budgetId) async {
  try {
    await _budgetService.deleteBudget(budgetId);
    budgets.value=budgets.where((budget) => budget.category != budgetId).toList();
    update(); // Updates the UI
  } catch (e) {
    Get.snackbar('Error', 'Failed to delete budget: $e');
  }
}

  void fetchPreferedAmount() async {
    try {
  isLoading.value=true;
  final user=await _usersRepository.fetchCurrentUser();
  preferedAmount=user.preferedCurrency;
  
  isLoading.value=false;
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
Future<void> fetchCategories() async {
    try {
      isLoading.value = true;
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
      categories.value = snapshot.docs
          .map((doc) => doc['name'] as String)
          .toList();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to fetch categories: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
   var budgets = <Budget>[].obs;

  // Fetch all budgets for the current user
  Future<void> fetchAllBudgets() async {
    try {
      budgets.value = await _budgetService.getAllBudgets();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch budgets: $e');
    }
  }

  // Update a budget
  Future<void> updateBudget( String category, double amount, DateTime date) async {
    try {
      await _budgetService.updateBudget( category, amount, date);
      // Update the local budgets list
      final index = budgets.indexWhere((budget) => budget.category == category);
      if (index != -1) {
        budgets[index] = budgets[index].copyWith(
          category: category,
          amount: amount,
          date: date,
        );
        budgets.refresh(); // Notify UI about the changes
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update budget: $e');
    }
  }
  Future<void> setBudget(String text, double parse) async {
    await _budgetService.setBudget(text, parse);
  }
}