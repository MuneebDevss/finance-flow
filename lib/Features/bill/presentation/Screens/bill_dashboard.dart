import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Features/bill/presentation/Screens/add_bill_page.dart';
import 'package:finance/Features/bill/presentation/Screens/bill_analytics_page.dart';
import 'package:finance/Features/bill/presentation/Screens/bill_history.dart';
import 'package:finance/Features/bill/presentation/controllers/bill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BillDashboardScreen extends StatelessWidget {
  final BillController controller = Get.put(BillController());

  BillDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigationWidget(5),
      appBar: AppBar(
        leading: Icon(Icons.receipt),
        elevation: 0,
        title: Text(
          'Smart Bill',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: 26),
            onPressed: () => Get.to(() => BillHistoryScreen()),
            tooltip: 'Payment History',
          ),
          IconButton(
            icon: Icon(Icons.analytics_outlined),
            onPressed: () => Get.to(() => BillAnalyticsPage()),
            tooltip: 'Payment History',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          }

          if (controller.upcomingBills.isEmpty) {
            return _buildEmptyState(context);
          }

          return _buildBillsList(context);
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddBillScreen()),
        icon: Icon(Icons.add),
        label: Text('Add Bill'),
        elevation: 4,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long,
              size: 80,
              color: Theme.of(context).primaryColor.withOpacity(0.7),
            ),
          ),
          SizedBox(height: 24),
          Text(
            'No Upcoming Bills',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Add your first bill to start tracking your expenses and never miss a payment again!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => Get.to(() => AddBillScreen()),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: Text(
              'Add Your First Bill',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillsList(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Upcoming Bills',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Chip(
                label: Text(
                  '${controller.upcomingBills.length} bills',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: controller.upcomingBills.length,
            itemBuilder: (context, index) {
              final bill = controller.upcomingBills[index];
              return _buildBillCard(context, bill);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBillCard(BuildContext context, bill) {
    final daysUntilDue = bill.dueDate.difference(DateTime.now()).inDays;
    final Color statusColor = _getDueDateColor(bill.dueDate);

    return Card(
      color: Color(0xFF435585),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showBillActions(context, bill),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getBillIcon(bill.name),
                      color: statusColor,
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bill.name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Due: ${_formatDate(bill.dueDate)}',
                          style: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      _getDueStatusText(daysUntilDue),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Divider(),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.sync, size: 16, color: Colors.grey[300]),
                      SizedBox(width: 4),
                      Text(
                        bill.recurrence,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                      SizedBox(width: 16),
                      Icon(Icons.credit_card,
                          size: 16, color: Colors.grey[300]),
                      SizedBox(width: 4),
                      Text(
                        bill.paymentMethod,
                        style: TextStyle(color: Colors.grey[300]),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '${bill.amount.toStringAsFixed(2)} ${controller.preferedAmount}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getBillIcon(String billName) {
    final name = billName.toLowerCase();
    if (name.contains('electric') || name.contains('power'))
      return Icons.electric_bolt;
    if (name.contains('water')) return Icons.water_drop;
    if (name.contains('internet') || name.contains('wifi')) return Icons.wifi;
    if (name.contains('phone') || name.contains('mobile'))
      return Icons.phone_android;
    if (name.contains('rent') ||
        name.contains('house') ||
        name.contains('mortgage')) return Icons.home;
    if (name.contains('car') || name.contains('vehicle'))
      return Icons.directions_car;
    if (name.contains('credit') || name.contains('card'))
      return Icons.credit_card;
    if (name.contains('loan') || name.contains('debt'))
      return Icons.account_balance;
    if (name.contains('tv') ||
        name.contains('television') ||
        name.contains('netflix')) return Icons.tv;
    if (name.contains('gas') || name.contains('fuel'))
      return Icons.local_gas_station;
    return Icons.receipt;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getDueDateColor(DateTime dueDate) {
    final daysUntilDue = dueDate.difference(DateTime.now()).inDays;

    if (daysUntilDue < 0) return Colors.red[700]!;
    if (daysUntilDue <= 3) return Colors.orange[700]!;
    return Colors.green[700]!;
  }

  String _getDueStatusText(int daysUntilDue) {
    if (daysUntilDue < 0) return 'Overdue';
    if (daysUntilDue == 0) return 'Due Today';
    if (daysUntilDue <= 3) return 'Due Soon';
    return 'Upcoming';
  }

  void _showBillActions(BuildContext context, bill) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text(
                'Bill Options',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.check_circle, color: Colors.green),
                ),
                title: Text('Mark as Paid'),
                subtitle:
                    Text('Record payment and create next bill if recurring'),
                onTap: () {
                  Get.back();
                  controller.markAsPaid(bill);
                  controller.scheduleNextPayment(bill);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.edit, color: Colors.blue),
                ),
                title: Text('Edit Bill Details'),
                subtitle: Text('Change amount, due date, or other details'),
                onTap: () {
                  Get.back();
                  Get.to(() => AddBillScreen(bill: bill));
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.delete, color: Colors.red),
                ),
                title: Text('Delete Bill'),
                subtitle: Text('Remove this bill permanently'),
                onTap: () {
                  Get.back();
                  _confirmDelete(context, bill);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, bill) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Bill'),
            ],
          ),
          content: Text(
              'Are you sure you want to delete this bill? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.back();
                controller.deleteBill(bill.id!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
