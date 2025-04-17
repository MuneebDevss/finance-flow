import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/zakat/data/model/assets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class AssetController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Form controllers
  final assetNameController = TextEditingController();
  final valueController = TextEditingController();
  final quantityController = TextEditingController();
  final notesController = TextEditingController();

  // Observable variables
  final selectedAssetType = ''.obs;
  final selectedDate = Rxn<DateTime>();
  final isLoading = false.obs;
  final assets = <AssetModel>[].obs;
  String preferedAmount = "";
  final UsersRepository _usersRepository = UsersRepository();
  // Asset type options
  final List<String> assetTypes = [
    'Gold',
    'Silver',
    'Cash',
    'Investments',
    'Property',
    'Other'
  ];

  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    selectedDate.value = DateTime.now();
    fetchAssets();
    fetchPreferedAmount();
  }

  void fetchPreferedAmount() async {
    try {
      isLoading.value = true;
      final user = await _usersRepository.fetchCurrentUser();
      preferedAmount = user.preferedCurrency;
      isLoading.value = false;
    } on Exception {}
  }

  @override
  void onClose() {
    assetNameController.dispose();
    valueController.dispose();
    quantityController.dispose();
    notesController.dispose();
    super.onClose();
  }

  void resetForm() {
    assetNameController.clear();
    valueController.clear();
    quantityController.clear();
    notesController.clear();
    selectedAssetType.value = '';
    selectedDate.value = DateTime.now();
  }

  Future<void> fetchAssets() async {
    try {
      isLoading.value = true;
      final userId = currentUserId;
      if (userId.isEmpty) return;

      final snapshot = await _firestore
          .collection('assets')
          .where('userId', isEqualTo: userId)
          .get();

      assets.value =
          snapshot.docs.map((doc) => AssetModel.fromFirestore(doc)).toList();
    } catch (e) {
      Get.snackbar('Error fetching assets:', '$e');
      HelpingFunctions.showSnackBar(Get.context!, "Failed to load assets");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addAsset() async {
    if (assetNameController.text.isEmpty ||
        valueController.text.isEmpty ||
        selectedAssetType.value.isEmpty ||
        selectedDate.value == null) {
      HelpingFunctions.showSnackBar(
          Get.context!, "All mandatory fields must be filled");
      return;
    }

    // Validate value is a valid number
    if (!RegExp(r'^\d*\.?\d+$').hasMatch(valueController.text)) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Value must contain only numbers");
      return;
    }

    // Validate value is not zero or negative
    double value = double.tryParse(valueController.text) ?? 0;
    if (value <= 0) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Value must be greater than zero");
      return;
    }

    // Validate quantity if provided
    double quantity = 1;
    if (quantityController.text.isNotEmpty) {
      if (!RegExp(r'^\d*\.?\d+$').hasMatch(quantityController.text)) {
        HelpingFunctions.showSnackBar(
            Get.context!, "Quantity must contain only numbers");
        return;
      }
      quantity = double.tryParse(quantityController.text) ?? 1;
    }

    try {
      isLoading.value = true;
      final userId = currentUserId;
      if (userId.isEmpty) {
        HelpingFunctions.showSnackBar(Get.context!, "User not logged in");
        return;
      }

      // Calculate if asset is zakatable based on type and value
      bool isZakatable =
          isAssetZakatable(selectedAssetType.value, value * quantity);

      await _firestore.collection('assets').add({
        'assetName': assetNameController.text,
        'assetType': selectedAssetType.value,
        'value': value,
        'quantity': quantity,
        'totalValue': value * quantity,
        'acquisitionDate': selectedDate.value,
        'notes': notesController.text,
        'isZakatable': isZakatable,
        'zakatIsPaid': false,
        'userId': userId,
        'createdAt': DateTime.now(),
      });

      await fetchAssets();
      resetForm();

      HelpingFunctions.showSnackBar(Get.context!, "Asset added successfully");
      Get.back();
    } catch (e) {
      HelpingFunctions.showSnackBar(Get.context!, "Failed to add asset: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Determine if asset is zakatable
  bool isAssetZakatable(String assetType, double value) {
    // Simplified logic - can be expanded based on Islamic rules
    switch (assetType) {
      case 'Gold':
        return value >= getNisabValue('Gold');
      case 'Silver':
        return value >= getNisabValue('Silver');
      case 'Cash':
      case 'Investments':
        return value >= getNisabValue('Cash');
      case 'Property':
        return false; // Typically property for personal use is not zakatable
      default:
        return false;
    }
  }

  // Get Nisab values (these should be updated regularly)
  double getNisabValue(String type) {
    // These are placeholder values - should be updated with current market rates
    switch (type) {
      case 'Gold':
        return 4500; // Value for ~85g of gold
      case 'Silver':
        return 600; // Value for ~595g of silver
      case 'Cash':
        return 4500; // Usually equivalent to gold nisab
      default:
        return 4500;
    }
  }

  Future<void> updateAsset(String assetId) async {
    if (assetNameController.text.isEmpty ||
        valueController.text.isEmpty ||
        selectedAssetType.value.isEmpty) {
      HelpingFunctions.showSnackBar(
          Get.context!, "All mandatory fields must be filled");
      return;
    }

    double value = double.tryParse(valueController.text) ?? 0;
    double quantity = double.tryParse(quantityController.text) ?? 1;

    try {
      isLoading.value = true;

      bool isZakatable =
          isAssetZakatable(selectedAssetType.value, value * quantity);

      await _firestore.collection('assets').doc(assetId).update({
        'assetName': assetNameController.text,
        'assetType': selectedAssetType.value,
        'value': value,
        'quantity': quantity,
        'totalValue': value * quantity,
        'acquisitionDate': selectedDate.value,
        'notes': notesController.text,
        'isZakatable': isZakatable,
        'updatedAt': DateTime.now(),
      });

      await fetchAssets();
      resetForm();

      HelpingFunctions.showSnackBar(Get.context!, "Asset updated successfully");
      Get.back();
    } catch (e) {
      HelpingFunctions.showSnackBar(Get.context!, "Failed to update asset: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAsset(String assetId) async {
    try {
      isLoading.value = true;
      await _firestore.collection('assets').doc(assetId).delete();
      await fetchAssets();
      HelpingFunctions.showSnackBar(Get.context!, "Asset deleted successfully");
    } catch (e) {
      HelpingFunctions.showSnackBar(Get.context!, "Failed to delete asset: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void loadAssetForEdit(AssetModel asset) {
    assetNameController.text = asset.assetName;
    valueController.text = asset.value.toString();
    quantityController.text = asset.quantity.toString();
    notesController.text = asset.notes;
    selectedAssetType.value = asset.assetType;
    selectedDate.value = asset.acquisitionDate;
  }
}
