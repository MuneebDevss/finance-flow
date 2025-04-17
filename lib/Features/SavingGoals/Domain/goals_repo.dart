import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/SavingGoals/Domain/saving_goal_entity.dart';

class SavingsService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final UsersRepository _repository = UsersRepository();

  Future<List<SavingsGoal>> getSavingsGoals() async {
    final currentUser = await _repository.fetchCurrentUser();
    final snapshot = await _db
        .collection('savings_goals')
        .where('userId', isEqualTo: currentUser.uid)
        .get();
    return snapshot.docs.map((doc) => SavingsGoal.fromFirestore(doc)).toList();
  }

  Future<void> createSavingsGoal(String name, double targetAmount, DateTime? deadline, String category) async {
    final currentUser = await _repository.fetchCurrentUser();
    await _db.collection('savings_goals').add({
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': 0.0,
      'deadline': deadline,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': currentUser.uid,
      'category': category, // New attribute
    });
  }

  Future<void> addFunds(String goalId, double amount) async {
    final goalRef = _db.collection('savings_goals').doc(goalId);
    await _db.runTransaction((transaction) async {
      final goalDoc = await transaction.get(goalRef);
      final currentAmount = (goalDoc.data()?['savedAmount'] as num).toDouble();
      transaction.update(goalRef, {'savedAmount': currentAmount + amount});
    });
  }

  Future<void> deleteSavingsGoal(String goalId) async {
    await _db.collection('savings_goals').doc(goalId).delete();
  }
}