import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/bill/data/models/PaymentHistory.dart';
import 'package:finance/Features/bill/data/models/bill.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class BillController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable lists
  final RxList<Bill> upcomingBills = <Bill>[].obs;
  final RxList<PaymentHistory> paymentHistory = <PaymentHistory>[].obs;
  String preferedAmount = "";
  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isAdding = false.obs;
  final UsersRepository _usersRepository = UsersRepository();
  // Current user ID (you should get this from your auth controller)
  String get userId =>
      FirebaseAuth.instance.currentUser?.uid ??
      ''; // Replace with actual user ID

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingBills();
    fetchPaymentHistory();
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

  Future<void> fetchUpcomingBills() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .orderBy('dueDate')
          .get();

      upcomingBills.value = snapshot.docs
          .map((doc) => Bill.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load bills: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchPaymentHistory() async {
    try {
      isLoading.value = true;

      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_history')
          .orderBy('paymentDate', descending: true)
          .get();

      paymentHistory.value = snapshot.docs
          .map((doc) => PaymentHistory.fromJson(doc.data(), doc.id))
          .toList();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load payment history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addBill(Bill bill) async {
    try {
      isAdding.value = true;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .add(bill.toJson());

      await fetchUpcomingBills();
      Get.back();
      Get.snackbar('Success', 'Bill added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add bill: $e');
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> markAsPaid(Bill bill) async {
    try {
      // Update bill status
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .doc(bill.id)
          .update({'status': 'paid'});

      // Add payment to history
      final payment = PaymentHistory(
        billId: bill.id!,
        billName: bill.name,
        amount: bill.amount,
        paymentDate: DateTime.now(),
        paymentMethod: bill.paymentMethod,
        status: 'Paid',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('payment_history')
          .add(payment.toJson());

      // Refresh data
      await fetchUpcomingBills();
      await fetchPaymentHistory();

      Get.snackbar('Success', 'Bill marked as paid');
    } catch (e) {
      Get.snackbar('Error', 'Failed to mark bill as paid: $e');
    }
  }

  Future<void> deleteBill(String billId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .doc(billId)
          .delete();

      await fetchUpcomingBills();
      Get.snackbar('Success', 'Bill deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete bill: $e');
    }
  }

  // For recurring bills
  Future<void> scheduleNextPayment(Bill bill) async {
    try {
      // Create the next bill based on recurrence
      DateTime nextDueDate;

      switch (bill.recurrence.toLowerCase()) {
        case 'weekly':
          nextDueDate = bill.dueDate.add(Duration(days: 7));
          break;
        case 'monthly':
          nextDueDate = DateTime(
            bill.dueDate.year,
            bill.dueDate.month + 1,
            bill.dueDate.day,
          );
          break;
        default:
          return; // Non-recurring bill
      }

      final newBill = Bill(
        name: bill.name,
        amount: bill.amount,
        dueDate: nextDueDate,
        recurrence: bill.recurrence,
        paymentMethod: bill.paymentMethod,
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('bills')
          .add(newBill.toJson());

      await fetchUpcomingBills();
    } catch (e) {
      Get.snackbar('Error', 'Failed to schedule next payment: $e');
    }
  }

  // Export payment history as CSV
  Future<String> exportPaymentHistory() async {
    // Implementation depends on how you want to handle file operations
    // This is a basic CSV string generation
    try {
      String csv = 'Bill Name,Amount,Payment Date,Payment Method,Status\n';

      for (var payment in paymentHistory) {
        csv +=
            '${payment.billName},${payment.amount},${payment.paymentDate.toString()},${payment.paymentMethod},${payment.status}\n';
      }

      return csv;
    } catch (e) {
      Get.snackbar('Error', 'Failed to export payment history: $e');
      return '';
    }
  }
}
