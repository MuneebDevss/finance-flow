import 'package:finance/Features/bill/presentation/controllers/bill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class BillHistoryScreen extends StatelessWidget {
  final BillController controller = Get.find<BillController>();

  BillHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bill Payment History'),
        actions: [
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _exportHistory,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        if (controller.paymentHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.history, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No payment history yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: controller.paymentHistory.length,
          itemBuilder: (context, index) {
            final payment = controller.paymentHistory[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: _getStatusIcon(payment.status),
                title: Text(
                  payment.billName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 4),
                    Text(
                        'Date: ${DateFormat('dd/MM/yyyy').format(payment.paymentDate)}'),
                    SizedBox(height: 4),
                    Text('Method: ${payment.paymentMethod}'),
                  ],
                ),
                trailing: Text(
                  '${controller.preferedAmount} ${payment.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _getStatusColor(payment.status),
                  ),
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return CircleAvatar(
          backgroundColor: Colors.green[100],
          child: Icon(Icons.check, color: Colors.green),
        );
      case 'failed':
        return CircleAvatar(
          backgroundColor: Colors.red[100],
          child: Icon(Icons.close, color: Colors.red),
        );
      case 'pending':
        return CircleAvatar(
          backgroundColor: Colors.orange[100],
          child: Icon(Icons.hourglass_empty, color: Colors.orange),
        );
      default:
        return CircleAvatar(
          backgroundColor: Colors.grey[100],
          child: Icon(Icons.help_outline, color: Colors.grey),
        );
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  void _exportHistory() async {
    final csvData = await controller.exportPaymentHistory();

    // Here you would typically save the file or share it
    // This requires platform-specific code or a plugin like share_plus

    Get.snackbar(
      'Export Complete',
      'Your payment history has been exported',
      duration: Duration(seconds: 3),
    );

    // Example using share_plus plugin (you would need to add it to pubspec.yaml)
    // import 'package:share_plus/share_plus.dart';
    // Share.shareFiles([filePath], text: 'Your payment history');
  }
}
