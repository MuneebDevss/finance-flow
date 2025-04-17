import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Debts/Domain/debt_entity.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';





class DebtRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final UsersRepository _usersRepository = UsersRepository();
  var isLoading=false.obs;
  String preferedAmount="";
  Future<void> addDebt(Debt debt) async {
    try {
      await _firestore.collection('debts').add(debt.toMap());
    } catch (e) {
      print('Error adding debt: $e');
      rethrow;
    }
  }
  Future<void> fetchPreferedAmount(bool updateDets) async {
    try {
  isLoading.value=true;
  final user=await _usersRepository.fetchCurrentUser();
  preferedAmount=user.preferedCurrency;
  if(updateDets)
  {
    getDebts(user.uid);
  }
  
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
  Future<void> updateDebt(Debt debt) async {
    try {
      await _firestore.collection('debts').doc(debt.id).update(debt.toMap());
    } catch (e) {
      print('Error updating debt: $e');
      rethrow;
    }
  }

  Future<void> deleteDebt(String debtId) async {
    try {
      await _firestore.collection('debts').doc(debtId).delete();
    } catch (e) {
      print('Error deleting debt: $e');
      rethrow;
    }
  }

  Stream<List<Debt>> getDebts(String userId) {
    try {
      return _firestore
          .collection('debts')
          .where('userId', isEqualTo: userId)
          .snapshots()
          .map((snapshot) =>
              snapshot.docs.map((doc) => Debt.fromSnapshot(doc)).toList());
    } catch (e) {
      print('Error fetching debts: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getSuggestedBudgetReductions(
      String userId, double requiredAmount) async {
    try {
      final budgetsSnapshot = await _firestore
          .collection('budgets')
          .where('userId', isEqualTo: userId)
          .get();

      final suggestions = <Map<String, dynamic>>[];
      for (var doc in budgetsSnapshot.docs) {
        final budget = doc.data();
        final amount = budget['amount'] as double;
        final reduction = amount * 0.1; // 10% reduction suggestion

        if (reduction > 0) {
          suggestions.add({
            'category': budget['category'],
            'currentAmount': amount,
            'suggestedReduction': reduction,
          });
        }
      }

      return suggestions;
    } catch (e) {
      print('Error fetching suggested budget reductions: $e');
      rethrow;
    }
  }
}

