import 'package:finance/Features/Debts/Domain/debt_entity.dart';
import 'package:finance/Features/Debts/Domain/debt_repo.dart';
import 'package:finance/Features/Debts/Presentation/Screens/debt_list.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatelessWidget {
  final List<Debt> debts;

  PaymentScreen({super.key, required this.debts});
  final DebtRepository repository = DebtRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Make a Payment'),
        backgroundColor: Colors.teal,
      ),
      body: ListView.builder(
        itemCount: debts.length,
        itemBuilder: (context, index) {
          final debt = debts[index];
          return Card(
            margin: EdgeInsets.all(8),
            elevation: 4,
            child: ListTile(
              title: Text(debt.name),
              subtitle: Text(
                'Remaining Balance: \$${debt.remainingBalance.toStringAsFixed(2)}',
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  _showPaymentDialog(context, debt);
                },
                child: Text('Pay'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPaymentDialog(BuildContext context, Debt debt) {
    final paymentController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Make a Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Debt: ${debt.name}'),
            SizedBox(height: 8),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Payment Amount',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final paymentAmount = double.tryParse(paymentController.text);
              if (paymentAmount != null && paymentAmount > 0) {
                Navigator.pop(context); // Close the dialog
                _processPayment(debt, paymentAmount);
              } else {
                Get.snackbar(
                  'Invalid Amount',
                  'Please enter a valid payment amount.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.teal,
              textStyle: Theme.of(context).textTheme.bodyMedium
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _processPayment(Debt debt, double paymentAmount) async {
    // Show loading indicator
    Get.dialog(
      Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );

    try {
      // Process payment logic
      debt.remainingBalance =
          (debt.remainingBalance - paymentAmount).clamp(0, debt.remainingBalance);

      // Simulate delay for testing (remove in production)
      await Future.delayed(Duration(seconds: 2));

      // Update debt in the repository
      await repository.updateDebt(debt);

      // Dismiss loading dialog and navigate
      Get.back(); // Close the loading dialog
      Get.offAll(() => DebtListScreen());

      Get.snackbar(
        'Success',
        'Payment of \$${paymentAmount.toStringAsFixed(2)} was successful.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Dismiss loading dialog and show error
      Get.back();
      Get.snackbar(
        'Error',
        'Payment failed. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}

