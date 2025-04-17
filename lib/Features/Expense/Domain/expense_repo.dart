import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Expense/Domain/expense_entity.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Your expense model

class ExpenseRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collectionPath = 'expenses';
  final _usersRepository =UsersRepository();
  Future<void> addExpense(Expense expense) async {
    try {
      final currentUser = await _usersRepository.fetchCurrentUser();

      await _db.collection(collectionPath).add({
        'name': expense.name,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date,
        'userId': currentUser.uid, // Add current user ID
      });
    } catch (e) {
      throw Exception('Failed to add expense');
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      final currentUser = await _usersRepository.fetchCurrentUser();

      await _db.collection(collectionPath).doc(expense.id).update({
        'name': expense.name,
        'amount': expense.amount,
        'category': expense.category,
        'date': expense.date,
        'userId': currentUser.uid, // Ensure user ownership
      });
    } catch (e) {
      throw Exception('Failed to update expense');
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _db.collection(collectionPath).doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete expense');
    }
  }

  Future<List<Expense>> getExpenses() async {
    try {
      final currentUser = await _usersRepository.fetchCurrentUser();

      QuerySnapshot snapshot = await _db
          .collection(collectionPath)
          .where('userId', isEqualTo: currentUser.uid) // Filter by user ID
          .get();

      return snapshot.docs.map((doc) {
        return Expense(
          id: doc.id,
          name: doc['name'],
          amount: doc['amount'],
          category: doc['category'],
          date: (doc['date'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses');
    }
  }

  Future<double> getTotalExpenses() async {
    try {
      final currentUser = await _usersRepository.fetchCurrentUser();

      QuerySnapshot snapshot = await _db
          .collection(collectionPath)
          .where('userId', isEqualTo: currentUser.uid) // Filter by user ID
          .get();

      double total = 0.0;
      snapshot.docs.forEach((doc) {
        if (doc['amount'] is double) {
          total += doc['amount'];
        }
      });

      return total;
    } catch (e) {
      throw Exception('Failed to calculate total expenses');
    }
  }

  Future<Map<String, double>> getCategoryBreakdown() async {
    try {
      final currentUser = await _usersRepository.fetchCurrentUser();

      QuerySnapshot snapshot = await _db
          .collection(collectionPath)
          .where('userId', isEqualTo: currentUser.uid) // Filter by user ID
          .get();

      Map<String, double> breakdown = {};
      for (var doc in snapshot.docs) {
        String category = doc['category'];
        double amount = doc['amount'];
        breakdown[category] = (breakdown[category] ?? 0) + amount;
      }
      return breakdown;
    } catch (e) {
      throw Exception('Failed to fetch category breakdown');
    }
  }
}


