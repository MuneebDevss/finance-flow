import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Income/Presentation/Controllers/income_controller.dart';
import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:finance/Features/zakat/data/model/zakat_payment_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ZakatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AssetController assetController = Get.put(AssetController());
  final IncomeController incomeController = Get.find<IncomeController>();

  // Observable variables
  final isLoading = false.obs;
  final totalZakatableAssets = 0.0.obs;
  final totalZakatableIncome = 0.0.obs;
  String preferedAmount = "";
  final UsersRepository _usersRepository = UsersRepository();
  final totalZakatDue = 0.0.obs;
  final zakatHistory = <ZakatPaymentModel>[].obs;
  String get currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';
  @override
  void onInit() {
    Future.microtask(() => calculateZakat());
    fetchZakatHistory();
    fetchPreferedAmount();
    super.onInit();
  }

  void fetchPreferedAmount() async {
    try {
      isLoading.value = true;
      final user = await _usersRepository.fetchCurrentUser();
      preferedAmount = user.preferedCurrency;
      isLoading.value = false;
    } on Exception {}
  }

  Future<void> calculateZakat() async {
    try {
      isLoading.value = true;

      // Ensure we have the latest data
      await assetController.fetchAssets();
      await incomeController.fetchIncomeEntries();

      // Calculate zakatable assets
      double assetTotal = 0;
      for (var asset in assetController.assets) {
        if (asset.isZakatable && !asset.zakatIsPaid) {
          assetTotal += asset.totalValue;
        }
      }
      totalZakatableAssets.value = assetTotal;

      // Calculate zakatable income
      double incomeTotal = 0;
      for (var income in incomeController.incomeEntries) {
        // Assuming we have a way to determine if income is zakatable
        // This could be based on income type, amount, or user selection
        if (!income['zakatIsPaid'] && income['amount'] > 135000) {
          incomeTotal += income['amount'];
        }
      }
      totalZakatableIncome.value = incomeTotal;

      // Calculate total Zakat due (2.5% of total)
      double total = assetTotal + incomeTotal;
      totalZakatDue.value = total * 0.025; // 2.5% is the standard Zakat rate
    } catch (e) {
      print('Error calculating Zakat: $e');
      HelpingFunctions.showSnackBar(Get.context!, "Failed to calculate Zakat");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchZakatHistory() async {
    try {
      isLoading.value = true;
      final userId = currentUserId;
      if (userId.isEmpty) return;

      final snapshot = await _firestore
          .collection('zakatPayments')
          .where('userId', isEqualTo: userId)
          .orderBy('paymentDate', descending: true)
          .get();

      zakatHistory.value = snapshot.docs
          .map((doc) => ZakatPaymentModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching Zakat history: $e');
      HelpingFunctions.showSnackBar(
          Get.context!, "Failed to load Zakat history");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> recordZakatPayment(double amount, List<String> assetIds,
      List<String> incomeIds, String notes) async {
    try {
      isLoading.value = true;
      final userId = currentUserId;
      if (userId.isEmpty) {
        HelpingFunctions.showSnackBar(Get.context!, "User not logged in");
        return;
      }

      // Record the payment
      await _firestore.collection('zakatPayments').add({
        'amount': amount,
        'paymentDate': DateTime.now(),
        'notes': notes,
        'assetIds': assetIds,
        'incomeIds': incomeIds,
        'userId': userId,
      });

      // Update assets as paid
      for (String assetId in assetIds) {
        await _firestore.collection('assets').doc(assetId).update({
          'zakatIsPaid': true,
          'zakatPaidDate': DateTime.now(),
        });
      }

      // Update income entries as paid
      for (String incomeId in incomeIds) {
        await _firestore.collection('incomeEntries').doc(incomeId).update({
          'zakatIsPaid': true,
          'zakatPaidDate': DateTime.now(),
        });
      }

      // Refresh data
      await fetchZakatHistory();
      await calculateZakat();

      HelpingFunctions.showSnackBar(
        Get.context!,
        "Zakat payment recorded successfully",
      );
    } catch (e) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Failed to record Zakat payment: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // Reset Zakat status for a new year
  Future<void> resetZakatStatus() async {
    try {
      isLoading.value = true;
      final userId = currentUserId;
      if (userId.isEmpty) return;

      // Reset assets
      final assetQuery = await _firestore
          .collection('assets')
          .where('userId', isEqualTo: userId)
          .where('zakatIsPaid', isEqualTo: true)
          .get();

      for (var doc in assetQuery.docs) {
        await doc.reference.update({
          'zakatIsPaid': false,
          'zakatPaidDate': null,
        });
      }

      // Reset income entries
      final incomeQuery = await _firestore
          .collection('incomeEntries')
          .where('userId', isEqualTo: userId)
          .where('zakatIsPaid', isEqualTo: true)
          .get();

      for (var doc in incomeQuery.docs) {
        await doc.reference.update({
          'zakatIsPaid': false,
          'zakatPaidDate': null,
        });
      }

      // Refresh data
      await calculateZakat();

      HelpingFunctions.showSnackBar(
          Get.context!, "Zakat status reset for new year");
    } catch (e) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Failed to reset Zakat status: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
