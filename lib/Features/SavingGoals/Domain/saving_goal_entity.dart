// savings_goal.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class SavingsGoal {
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime? deadline;
  final DateTime createdAt;
  final String userId;
  final String category; // New attribute

  SavingsGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    this.deadline,
    required this.createdAt,
    required this.userId,
    required this.category, // New attribute
  });

  factory SavingsGoal.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SavingsGoal(
      id: doc.id,
      name: data['name'],
      targetAmount: (data['targetAmount'] as num).toDouble(),
      savedAmount: (data['savedAmount'] as num).toDouble(),
      deadline: data['deadline'] != null ? (data['deadline'] as Timestamp).toDate() : null,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      userId: data['userId'],
      category: data['category'], // New attribute
    );
  }
}




// savings_service.dart


// savings_controller.dart


// savings_page.dart


// savings_binding.dart
