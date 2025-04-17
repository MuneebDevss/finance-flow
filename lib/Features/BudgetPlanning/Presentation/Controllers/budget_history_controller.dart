import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/BudgetPlanning/Domain/budget_repos.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class BudgetHistoryController extends GetxController {
  final BudgetService _budgetService = BudgetService();
  final _selectedDate = DateTime.now().obs;
  final _budgetReport = Rxn<Map<String, dynamic>>();
  final _isLoading = false.obs;
  final UsersRepository _usersRepository = UsersRepository();
  DateTime get selectedDate => _selectedDate.value;
  Map<String, dynamic>? get budgetReport => _budgetReport.value;
  bool get isLoading => _isLoading.value;
  String preferedAmount="";
  @override
  void onInit() {
    super.onInit();
    fetchPreferedAmount();
    fetchBudgetReport();
  }

  void updateDate(DateTime date) {
    _selectedDate.value = date;
    fetchBudgetReport();
  }
  void fetchPreferedAmount() async {
    try {
  final user=await _usersRepository.fetchCurrentUser();
  preferedAmount=user.preferedCurrency;
  
  
} on Exception catch (e) {
   Get.snackbar(
        "Error",
        "Failed to fetch Prefered amount: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
}
    }
  Future<void> fetchBudgetReport() async {
    _isLoading.value = true;
    try {
      final report = await _budgetService.getMonthlyBudgetReport(_selectedDate.value);
      _budgetReport.value = report;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load budget report $e');
    } finally {
      _isLoading.value = false;
    }
  }
}