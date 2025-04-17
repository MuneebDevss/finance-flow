import 'dart:async';

import 'package:finance/Features/stocks/Data/price_update_service.dart';
import 'package:finance/Features/stocks/Data/stock_data_source.dart';
import 'package:finance/Features/stocks/Data/stocks_asset.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StockAssetController extends GetxController {
  final FirebaseService _firebaseService = Get.put(FirebaseService());
  final PriceUpdateService _priceService = PriceUpdateService();

  RxList<Asset> assets = <Asset>[].obs;
  RxBool isLoading = false.obs;

  

  final isRefreshing = false.obs;

  // Sorting options
  final sortOption = 'Value'.obs;

  // Filter options
  final showStocks = true.obs;
  final showCrypto = true.obs;
  final showETFs = true.obs;
  final showBonds = true.obs;
  final performanceRange = RangeValues(-100.0, 100.0).obs;
  void sortAssets() {
    switch (sortOption.value) {
      case 'Value':
        assets.sort((a, b) => (b.currentPrice * b.quantity)
            .compareTo(a.currentPrice * a.quantity));
        break;
      case 'Name':
        assets.sort((a, b) => a.name.compareTo(b.name));
        break;
      case 'Performance':
        assets.sort((a, b) => b.returnPercentage.compareTo(a.returnPercentage));
        break;
      case 'Purchase Date':
        assets.sort((a, b) => b.purchaseDate.compareTo(a.purchaseDate));
        break;
    }

    // Refresh the UI
    assets.refresh();
    
  }

  

  

  @override
  void onInit() {
    super.onInit();
    fetchAssets();
    _priceService.startPriceUpdates();
  }

  @override
  void onClose() {
    _priceService.stopPriceUpdates();
    super.onClose();
  }

  Future<void> fetchAssets() async {
    isLoading.value = true;
    assets.value = await _firebaseService.getAssets();
    isLoading.value = false;
  }

  Future<bool> addAsset(Asset asset) async {
    isLoading.value = true;

    // Get latest price before adding
    double latestPrice = await _priceService.getLatestPrice(asset);
    asset.currentPrice = latestPrice;

    bool success = await _firebaseService.addAsset(asset);
    if (success) {
      await fetchAssets();
    }

    isLoading.value = false;
    return success;
  }

  Future<bool> updateAsset(Asset asset) async {
    isLoading.value = true;
    bool success = await _firebaseService.updateAsset(asset);
    if (success) {
      await fetchAssets();
    }
    isLoading.value = false;
    return success;
  }

  Future<bool> deleteAsset(String assetId) async {
    isLoading.value = true;
    bool success = await _firebaseService.deleteAsset(assetId);
    if (success) {
      await fetchAssets();
    }
    isLoading.value = false;
    return success;
  }

  Future<void> refreshPrices() async {
    isLoading.value = true;
    await _priceService.updateAllPrices();
    await fetchAssets();
    isLoading.value = false;
  }

  double getTotalPortfolioValue() {
    return assets.fold(0, (sum, asset) => sum + asset.currentValue);
  }

  double getTotalInvestment() {
    return assets.fold(0, (sum, asset) => sum + asset.totalInvestment);
  }

  double getTotalProfitLoss() {
    return getTotalPortfolioValue() - getTotalInvestment();
  }

  double getTotalReturnPercentage() {
    double totalInvestment = getTotalInvestment();
    return totalInvestment > 0
        ? (getTotalProfitLoss() / totalInvestment) * 100
        : 0;
  }

  List<Asset> getAssetsByType(String assetType) {
    return assets.where((asset) => asset.assetType == assetType).toList();
  }
}
