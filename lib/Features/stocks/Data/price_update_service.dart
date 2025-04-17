import 'dart:async';

import 'package:finance/Features/stocks/Data/stock_api_impl.dart';
import 'package:finance/Features/stocks/Data/stock_data_source.dart';
import 'package:finance/Features/stocks/Data/stocks_asset.dart';

class PriceUpdateService {
  // final StockPriceService _stockService = StockPriceService();
  final CryptoPriceService _cryptoService = CryptoPriceService();
  final FirebaseService _firebaseService = FirebaseService();

  Timer? _timer;

  void startPriceUpdates({int seconds = 15}) {
     updateAllPrices();
  }

  void stopPriceUpdates() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> updateAllPrices() async {
    try {
      final assets = await _firebaseService.getAssets();

      for (final asset in assets) {
        double price = 0.0;

        // Different price fetching logic based on asset type
        if (asset.assetType == 'stock') {
          // price = await _stockService.fetchPrice(asset.name);
        } else if (asset.assetType == 'crypto') {
          price = await _cryptoService.fetchPrice(asset.name);
        }
        // Only update if we got a valid price
        if (price > 0) {
          asset.currentPrice = price;
          await _firebaseService.updateAsset(asset);
        }
      }
    } catch (e) {
      print('Error updating prices: $e');
    }
  }

  Future<double> getLatestPrice(Asset asset) async {
    try {
      double price = 0.0;

      if (asset.assetType == 'stock') {
        // price = await _stockService.fetchPrice(asset.name);
      } else if (asset.assetType == 'crypto') {
        price = await _cryptoService.fetchPrice(asset.name);
      }

      return price > 0 ? price : asset.currentPrice;
    } catch (e) {
      print('Error getting latest price: $e');
      return asset.currentPrice;
    }
  }
}
