import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_entity.dart';

// Updated BudgetService
class BudgetService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UsersRepository _repository = UsersRepository();

  // Get all budgets for the current user
  Future<List<Budget>> getAllBudgets() async {
    try {
      final currentUser = await _repository.fetchCurrentUser();

      final snapshot = await _db
          .collection('budgets')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch budgets: $e');
    }
  }

  // Get current month's budget for the current user
  Future<List<Budget>> fetchCurrentMonthBudgets() async {
    try {
      final currentUser = await _repository.fetchCurrentUser();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _db
          .collection('budgets')
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      return snapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch current month budgets: $e');
    }
  }

  // Set budget for a category for the current user
  Future<void> setBudget(String category, double amount) async {
    try {
      final currentUser = await _repository.fetchCurrentUser();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

        await _db.collection('budgets').doc(category).set({
        'category': category,
        'amount': amount,
        'date': startOfMonth,
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': currentUser.uid,
      });
    } catch (e) {
      throw Exception('Failed to set budget: $e');
    }
  }
  Future<void> updateBudget( String category, double amount, DateTime date) async {
    try {
      final currentUser = await _repository.fetchCurrentUser();

      await _db.collection('budgets').doc(category).update({
        'category': category,
        'amount': amount,
        'date': date,
        'updatedAt': FieldValue.serverTimestamp(),
        'userId': currentUser.uid, // Ensure user ID is retained
      });
    } catch (e) {
      throw Exception('Failed to update budget: $e');
    }
  }
  // Get current month's expenses for the current user
  Future<List<BudgetExpense>> getCurrentMonthExpenses() async {
    try {
      final currentUser = await _repository.fetchCurrentUser();

      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final snapshot = await _db
          .collection('expenses')
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      return snapshot.docs.map((doc) => BudgetExpense.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch expenses: $e');
    }
  }
  Future<Map<String, dynamic>> getMonthlyBudgetReport(DateTime date) async {
    try {
      final currentUser = await _repository.fetchCurrentUser();
      final startOfMonth = DateTime(date.year, date.month, 1);
      final endOfMonth = DateTime(date.year, date.month + 1, 0, 23, 59, 59);

      // Fetch budgets
      final budgetSnapshot = await _db
          .collection('budgets')
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      // Fetch expenses
      final expenseSnapshot = await _db
          .collection('expenses')
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .where('date', isLessThanOrEqualTo: endOfMonth)
          .get();

      final budgets = budgetSnapshot.docs.map((doc) => Budget.fromFirestore(doc)).toList();
      final expenses = expenseSnapshot.docs.map((doc) => BudgetExpense.fromFirestore(doc)).toList();

      // Group expenses by category
      Map<String, double> expensesByCategory = {};
      for (var expense in expenses) {
        expensesByCategory[expense.category] = (expensesByCategory[expense.category] ?? 0) + expense.amount;
      }

      return {
        'budgets': budgets,
        'expenses': expensesByCategory,
      };
    } catch (e) {
      throw Exception('Failed to fetch monthly report: $e');
    }
  }

  // Get real-time updates for expenses for the current user
  Stream<QuerySnapshot> getExpenseStream() {
    return Stream.fromFuture(_repository.fetchCurrentUser()).asyncExpand((currentUser) {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      return _db
          .collection('expenses')
          .where('userId', isEqualTo: currentUser.uid)
          .where('date', isGreaterThanOrEqualTo: startOfMonth)
          .snapshots();
    });
  }
  Future<void> deleteBudget(String budgetId) async {
  try {
    await _db.collection('budgets').doc(budgetId).delete();
  } catch (e) {
    throw Exception('Failed to delete budget: $e');
  }
}

}