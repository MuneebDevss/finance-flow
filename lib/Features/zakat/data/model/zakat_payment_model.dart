import 'package:cloud_firestore/cloud_firestore.dart';

class ZakatPaymentModel {
  final String id;
  final double amount;
  final DateTime paymentDate;
  final String notes;
  final List<String> assetIds;
  final List<String> incomeIds;
  final String userId;
  
  ZakatPaymentModel({
    required this.id,
    required this.amount,
    required this.paymentDate,
    required this.notes,
    required this.assetIds,
    required this.incomeIds,
    required this.userId,
  });
  
  factory ZakatPaymentModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ZakatPaymentModel(
      id: doc.id,
      amount: (data['amount'] ?? 0).toDouble(),
      paymentDate: (data['paymentDate'] as Timestamp).toDate(),
      notes: data['notes'] ?? '',
      assetIds: List<String>.from(data['assetIds'] ?? []),
      incomeIds: List<String>.from(data['incomeIds'] ?? []),
      userId: data['userId'] ?? '',
    );
  }
}