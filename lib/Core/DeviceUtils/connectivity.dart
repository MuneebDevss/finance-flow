import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Manages the network connectivity status and provides methods to check and handle connectivity changes.
class NetworkManager extends GetxController {
  static NetworkManager get instance => Get.find();

  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  


  /// Initialize the network manager and set up a stream to continually check the connection status.
  @override
  Future<void> onInit() async {
    super.onInit();
    
  }


  

  /// Check the internet connection status.
  /// Returns true if connected, false otherwise.
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result.contains(ConnectivityResult.wifi)||
       result.contains(ConnectivityResult.ethernet)||
       result.contains(ConnectivityResult.mobile);
    } catch (e) {
      return false;
    }
  }

  @override
  void onClose() {
    super.onClose();
    _connectivitySubscription.cancel(); // Cancel the subscription to avoid memory leaks
  }
}
