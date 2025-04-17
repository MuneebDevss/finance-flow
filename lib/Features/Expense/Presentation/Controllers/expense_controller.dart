import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Expense/Domain/expense_entity.dart';
import 'package:finance/Features/Expense/Domain/expense_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Your Firestore service
    
class ExpenseController extends GetxController {
  final ExpenseRepository firestoreService;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
    final UsersRepository _usersRepository = UsersRepository();
     String preferedAmount="";
  ExpenseController(this.firestoreService);
  int selected=1;
  var expenses = <Expense>[].obs;
  var totalExpenses = 0.0.obs;
  var categoryBreakdown = <String, double>{}.obs;
  final RxList<String> categories = <String>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchExpenses();
    fetchCategories();
    fetchPreferedAmount();
  }
  
   String get currentUserId => _auth.currentUser?.uid ?? '';

  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
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
  void addExpense(String name, double amount, String category) async {
    try {
      isLoading.value = true;
      final expense = Expense(
        id: '',
        name: name,
        amount: amount,
        category: category,
        date: DateTime.now(),
      );
      await firestoreService.addExpense(expense);
      fetchExpenses(); // Refresh the expense list
    } catch (e) {
      errorMessage.value = 'Failed to add expense';
    } finally {
      isLoading.value = false;
    }
  }

  void updateExpense(Expense expense) async {
    try {
      isLoading.value = true;
      await firestoreService.updateExpense(expense);
      fetchExpenses(); // Refresh the expense list
    } catch (e) {
      errorMessage.value = 'Failed to update expense';
    } finally {
      isLoading.value = false;
    }
  }

  void deleteExpense(String id) async {
    try {
      isLoading.value = true;
      await firestoreService.deleteExpense(id);
      fetchExpenses(); // Refresh the expense list
    } catch (e) {
      errorMessage.value = 'Failed to delete expense';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchExpenses() async {
    try {
      isLoading.value = true;
      expenses.value = await firestoreService.getExpenses();
      totalExpenses.value = await firestoreService.getTotalExpenses();
      categoryBreakdown.value = await firestoreService.getCategoryBreakdown();
    } catch (e) {
      errorMessage.value = 'Failed to fetch expenses';
    } finally {
      isLoading.value = false;
    }
  }
}
