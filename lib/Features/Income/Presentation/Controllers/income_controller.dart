import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_page_.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class IncomeController extends GetxController {
  int selected=0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxList<Map<String, dynamic>> incomeEntries = <Map<String, dynamic>>[].obs;
  final RxList<String> categories = <String>[].obs;
  final RxBool isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UsersRepository _usersRepository = UsersRepository();
  final TextEditingController sourceNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final RxString selectedCategory = ''.obs;
  RxDouble totalExpense=0.0.obs;
  String currentUsersName="";
  final Rx<DateTime?> selectedDate = Rx(null);
  String preferedAmount="";
  // Get current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';
  // In IncomeController class, add this new method:
Future<void> updateIncomeEntry(String incomeId) async {
  if (sourceNameController.text.isEmpty ||
      amountController.text.isEmpty ||
      selectedCategory.value.isEmpty ||
      selectedDate.value == null) {
    HelpingFunctions.showSnackBar(Get.context!, "All mandatory fields must be filled");
    return;
  }

  // Check if amount contains only numbers and decimal point
  if (!RegExp(r'^\d*\.?\d+$').hasMatch(amountController.text)) {
    HelpingFunctions.showSnackBar(Get.context!, "Amount must contain only numbers");
    return;
  }

  // Validate amount is not zero or negative
  double amount = double.tryParse(amountController.text) ?? 0;
  if (amount <= 0) {
    HelpingFunctions.showSnackBar(Get.context!, "Amount must be greater than zero");
    return;
  }

  // Optional: Check for reasonable maximum amount
  if (amount > 999999999) {
    HelpingFunctions.showSnackBar(Get.context!, "Amount seems too large. Please verify");
    return;
  }

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

    await _firestore.collection('incomeEntries').doc(incomeId).update({
      'sourceName': sourceNameController.text,
      'amount': double.parse(amountController.text),
      'dateReceived': selectedDate.value,
      'category': selectedCategory.value,
      'notes': notesController.text,
      'userId': userId,
    });

    await fetchIncomeEntries();
    Get.snackbar(
      "Success",
      "Income entry updated successfully",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );
    Get.offAll(() => IncomeListPage());
  } catch (e) {
    Get.snackbar(
      "Error",
      "Failed to update income entry: $e",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
    );
  } finally {
    isLoading.value = false;
  }
}

// Modified ElevatedButton:
void fetchPreferedAmount() async {
    try {
  isLoading.value=true;
  final user=await _usersRepository.fetchCurrentUser();
  preferedAmount=user.preferedCurrency;
  
  currentUsersName=user.name;
  
  isLoading.value=false;
} on Exception {
   
}
    }
  // Fetch income entries specific to the current user
  Future<void> fetchIncomeEntries() async {
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
          .collection('incomeEntries')
          .where('userId', isEqualTo: userId)  // Filter by user ID
          .get();
      incomeEntries.value =
          snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    } catch (e) {

    } finally {
      isLoading.value = false;
    }
  }

  // Fetch categories specific to the current user
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
          .doc('incomeCategoriesDocs')
          .collection('items')
          .where('userId', isEqualTo: userId)  // Filter by user ID
          .get();
      categories.value =
          snapshot.docs.map((doc) => doc['name'] as String).toList();
    } catch (e) {
      
    } finally {
      isLoading.value = false;
    }
  }
  Future<void> getTotalExpenses() async {
    try {
      isLoading.value=true;
      final currentUser = await _usersRepository.fetchCurrentUser();

      QuerySnapshot snapshot = await _firestore
          .collection("expenses")
          .where('userId', isEqualTo: currentUser.uid) // Filter by user ID
          .get();

      double total = 0.0;
      snapshot.docs.forEach((doc) {
        if (doc['amount'] is double) {
          total += doc['amount'];
        }
      });

      totalExpense.value= total;
      isLoading.value=false;
    } catch (e) {
      throw Exception('Failed to calculate total expenses');
    }
  }
  // Add income entry with the current user's ID
  Future<void> addIncomeEntry() async {
    if (sourceNameController.text.isEmpty ||
    amountController.text.isEmpty ||
    selectedCategory.value.isEmpty ||
    selectedDate.value == null) {
  HelpingFunctions.showSnackBar(Get.context!, "All mandatory fields must be filled");
  return;
}

  // Check if amount contains only numbers and decimal point
  if (!RegExp(r'^\d*\.?\d+$').hasMatch(amountController.text)) {
    HelpingFunctions.showSnackBar(Get.context!, "Amount must contain only numbers");
    return;
  }

  // Validate amount is not zero or negative
  double amount = double.tryParse(amountController.text) ?? 0;
  if (amount <= 0) {
    HelpingFunctions.showSnackBar(Get.context!, "Amount must be greater than zero");
    return;
  }

  // Optional: Check for reasonable maximum amount (e.g., prevent typos)
  if (amount > 999999999) {  // Adjust this limit as needed
    HelpingFunctions.showSnackBar(Get.context!, "Amount seems too large. Please verify");
    return;
}

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

      await _firestore.collection('incomeEntries').add({
        'sourceName': sourceNameController.text,
        'amount': double.parse(amountController.text),
        'dateReceived': selectedDate.value,
        'category': selectedCategory.value,
        'notes': notesController.text,
        'zakatIsPaid':false,
        'userId': userId, // Store the current user's ID
      });
      await fetchIncomeEntries();
      Get.snackbar(
        "Success",
        "Income entry added successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.offAll(()=>IncomeListPage());
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to add income entry: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Edit income entry with the current user's ID
  Future<void> editIncomeEntry(String id, Map<String, dynamic> updatedData) async {
    try {
      isLoading.value = true;
      await _firestore.collection('incomeEntries').doc(id).update(updatedData);
      await fetchIncomeEntries();
      Get.snackbar(
        "Success",
        "Income entry updated successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to update income entry: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Delete income entry with the current user's ID
  Future<void> deleteIncomeEntry(String id) async {
    try {
      isLoading.value = true;
      await _firestore.collection('incomeEntries').doc(id).delete();
      await fetchIncomeEntries();
      Get.snackbar(
        "Success",
        "Income entry deleted successfully",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete income entry: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Clear input fields
  void clearInputs() {
    sourceNameController.clear();
    amountController.clear();
    notesController.clear();
    selectedCategory.value = '';
    selectedDate.value = null;
  }
}