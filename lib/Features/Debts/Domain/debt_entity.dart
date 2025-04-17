// models/debt.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Debt {
  final String id;
  final String name;
  final double totalAmount;
   double remainingBalance;
  final DateTime? dueDate;
  final String userId;
  final DateTime createdAt;

  Debt({
    required this.id,
    required this.name,
    required this.totalAmount,
    required this.remainingBalance,
    this.dueDate,
    required this.userId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalAmount': totalAmount,
      'remainingBalance': remainingBalance,
      'dueDate': dueDate,
      'userId': userId,
      'createdAt': createdAt,
    };
  }

  factory Debt.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    return Debt(
      id: snapshot.id,
      name: data['name'],
      totalAmount: data['totalAmount'],
      remainingBalance: data['remainingBalance'],
      dueDate: data['dueDate']?.toDate(),
      userId: data['userId'],
      createdAt: data['createdAt'].toDate(),
    );
  }

  double getMonthlyPayment() {
    if (dueDate == null) return 0;
    
    final now = DateTime.now();
    final months = (dueDate!.year - now.year) * 12 + dueDate!.month - now.month;
    return months > 0 ? remainingBalance / months : remainingBalance;
  }
}

// repositories/debt_repository.dart


// screens/debt_list_screen.dart


// widgets/debt_list_tile.dart


// utils/notification_service.dart
class NotificationService {
  static Future<void> checkAndNotify(Debt debt) async {
    final monthlyPayment = debt.getMonthlyPayment();
    
    if (debt.dueDate != null) {
      final daysUntilDue = debt.dueDate!.difference(DateTime.now()).inDays;
      
      if (daysUntilDue <= 7) {
        await _showNotification(
          'Payment Due Soon',
          'You need to pay \$${monthlyPayment.toStringAsFixed(2)} for ${debt.name}',
        );
      }
    }
  }

  static Future<void> checkInsufficientFunds(
      double requiredAmount, List<Map<String, dynamic>> suggestions) async {
    if (suggestions.isNotEmpty) {
      final message = suggestions.map((s) =>
          'Reduce ${s['category']} by \$${s['suggestedReduction'].toStringAsFixed(2)}')
          .join('\n');
          
      await _showNotification(
        'Insufficient Funds Warning',
        'Suggested budget adjustments:\n$message',
      );
    }
  }

  static Future<void> _showNotification(String title, String body) async {
    // Implement actual notification logic here using your preferred notification package
    print('Notification: $title - $body');
  }
}