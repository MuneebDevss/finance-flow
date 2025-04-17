import 'package:cloud_firestore/cloud_firestore.dart';
class PaymentHistory {
  String? id;
  String billId;
  String billName;
  double amount;
  DateTime paymentDate;
  String paymentMethod;
  String status; // Paid, Failed, Pending
  
  PaymentHistory({
    this.id,
    required this.billId,
    required this.billName,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    required this.status,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'billId': billId,
      'billName': billName,
      'amount': amount,
      'paymentDate': Timestamp.fromDate(paymentDate),
      'paymentMethod': paymentMethod,
      'status': status,
    };
  }
  
  factory PaymentHistory.fromJson(Map<String, dynamic> json, String id) {
    return PaymentHistory(
      id: id,
      billId: json['billId'],
      billName: json['billName'],
      amount: json['amount'],
      paymentDate: (json['paymentDate'] as Timestamp).toDate(),
      paymentMethod: json['paymentMethod'],
      status: json['status'],
    );
  }
}