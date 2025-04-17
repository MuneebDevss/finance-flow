import 'package:cloud_firestore/cloud_firestore.dart';

class Budget {
  final double amount;
  final String category;
  final DateTime date;
 

  Budget({
 
    required this.date,
    required this.amount,
    required this.category,
  });

  factory Budget.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Budget(
      amount: (data['amount'] as num).toDouble(),
      date: (data['date'] as Timestamp).toDate(),
      category: doc.id,
   
    );
  }

  Budget copyWith({
    double? amount,
    String? category,
    DateTime? date,
    String? id,
  }) {
    return Budget(
      date: date ?? this.date,
      amount: amount ?? this.amount,
      category: category ?? this.category,
    );
  }
}
class BudgetExpense {
  final double amount;
  final String category;
  final DateTime date;
  
  BudgetExpense({
    required this.amount,
    required this.category,
    required this.date,
  });
  
  factory BudgetExpense.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BudgetExpense(
      amount: (data['amount'] as num).toDouble(),
      category: data['category'],
      date: (data['date'] as Timestamp).toDate(),
    );
  }
}