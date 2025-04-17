// MODEL
// lib/models/bill.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  String? id;
  String name;
  double amount;
  DateTime dueDate;
  String recurrence; // monthly, weekly, etc.
  String paymentMethod;
  String status; // upcoming, paid, overdue
  String category; // loan, utility, credit, rent, etc.

  Bill({
    this.id,
    required this.name,
    required this.amount,
    required this.dueDate,
    required this.recurrence,
    required this.paymentMethod,
    this.status = 'upcoming',
    this.category = 'Other', // Default category
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'dueDate': Timestamp.fromDate(dueDate),
      'recurrence': recurrence,
      'paymentMethod': paymentMethod,
      'status': status,
      'category': category,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> json, String id) {
    return Bill(
      id: id,
      name: json['name'],
      amount: json['amount'],
      dueDate: (json['dueDate'] as Timestamp).toDate(),
      recurrence: json['recurrence'],
      paymentMethod: json['paymentMethod'],
      status: json['status'],
      category: json['category'] ?? 'Other',
    );
  }
}



// MAIN.DART INTEGRATION
// Add these routes to your GetMaterialApp in main.dart
/*
GetMaterialApp(
  // other configurations
  getPages: [
    GetPage(name: '/bills', page: () => BillDashboardScreen()),
    GetPage(name: '/bills/add', page: () => AddBillScreen()),
    GetPage(name: '/bills/history', page: () => BillHistoryScreen()),
  ],
)
*/