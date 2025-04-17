import 'package:cloud_firestore/cloud_firestore.dart';

class AssetModel {
  final String id;
  final String assetName;
  final String assetType;
  final double value;
  final double quantity;
  final double totalValue;
  final DateTime acquisitionDate;
  final String notes;
  final bool isZakatable;
  final bool zakatIsPaid;
  final String userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AssetModel({
    required this.id,
    required this.assetName,
    required this.assetType,
    required this.value,
    required this.quantity,
    required this.totalValue,
    required this.acquisitionDate,
    required this.notes,
    required this.isZakatable,
    required this.zakatIsPaid,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory AssetModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // Handle acquisitionDate which is causing the error
    DateTime? acquisitionDate;
    if (data['acquisitionDate'] != null) {
      acquisitionDate = (data['acquisitionDate'] as Timestamp).toDate();
    } else {
      acquisitionDate = DateTime.now(); // Default if null
    }

    // Handle createdAt and updatedAt with proper null checking
    DateTime? createdAt;
    if (data['createdAt'] != null) {
      createdAt = (data['createdAt'] as Timestamp).toDate();
    } else {
      createdAt = DateTime.now();
    }

    DateTime? updatedAt;
    if (data['updatedAt'] != null) {
      updatedAt = (data['updatedAt'] as Timestamp).toDate();
    } else {
      updatedAt = DateTime.now();
    }

    return AssetModel(
      id: doc.id,
      assetName: data['assetName'] ?? '',
      assetType: data['assetType'] ?? '',
      value: (data['value'] ?? 0).toDouble(),
      quantity: (data['quantity'] ?? 1).toDouble(),
      totalValue: (data['totalValue'] ?? 0).toDouble(),
      acquisitionDate: acquisitionDate,
      notes: data['notes'] ?? '',
      isZakatable: data['isZakatable'] ?? false,
      zakatIsPaid: data['zakatIsPaid'] ?? false,
      userId: data['userId'] ?? '',
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
