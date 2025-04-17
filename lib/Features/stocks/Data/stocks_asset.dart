// CORE MODELS

class Asset {
  String id;
  String name;
  String assetType; // stock, mutualFund, realEstate, crypto, other
  double purchasePrice;
  double currentPrice;
  double quantity;
  DateTime purchaseDate;
  String userId;
  Map<String, dynamic> additionalInfo; // For asset-specific additional data
  
  Asset({
    required this.id,
    required this.name,
    required this.assetType,
    required this.purchasePrice,
    this.currentPrice = 0.0,
    required this.quantity,
    required this.purchaseDate,
    required this.userId,
    this.additionalInfo = const {},
  });
  
  double get totalInvestment => purchasePrice * quantity;
  double get currentValue => currentPrice * quantity;
  double get profitLoss => currentValue - totalInvestment;
  double get returnPercentage => (profitLoss / totalInvestment) * 100;
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'assetType': assetType,
      'purchasePrice': purchasePrice,
      'currentPrice': currentPrice,
      'quantity': quantity,
      'purchaseDate': purchaseDate.toIso8601String(),
      'userId': userId,
      'additionalInfo': additionalInfo,
    };
  }
  
  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      id: json['id'],
      name: json['name'],
      assetType: json['assetType'],
      purchasePrice: json['purchasePrice'],
      currentPrice: json['currentPrice'] ?? 0.0,
      quantity: json['quantity'],
      purchaseDate: DateTime.parse(json['purchaseDate']),
      userId: json['userId'],
      additionalInfo: json['additionalInfo'] ?? {},
    );
  }
}