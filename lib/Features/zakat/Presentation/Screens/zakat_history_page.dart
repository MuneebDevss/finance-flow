import 'package:finance/Features/zakat/Presentation/Screens/payzakat_page.dart';
import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:finance/Features/zakat/Presentation/controller/zakat_controller.dart';
import 'package:finance/Features/zakat/data/model/assets.dart';
import 'package:finance/Features/zakat/data/model/zakat_payment_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class ZakatHistoryPage extends StatelessWidget {
  final ZakatController zakatController = Get.put(ZakatController());

  ZakatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Payment History',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [
          Tooltip(
            message: 'Refresh History',
            child: IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => zakatController.fetchZakatHistory(),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (zakatController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (zakatController.zakatHistory.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child:
                      const Icon(Icons.history, size: 72, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Zakat Payment History',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Your Zakat payment records will appear here',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () => Get.to(() => PayZakatPage()),
                  icon: const Icon(Icons.payment),
                  label: const Text('Pay Zakat Now'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            // Summary section
            _buildSummarySection(context),
            // Payment history list
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  await zakatController.fetchZakatHistory();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: zakatController.zakatHistory.length,
                  itemBuilder: (context, index) {
                    final payment = zakatController.zakatHistory[index];
                    return _buildPaymentCard(context, payment);
                  },
                ),
              ),
            ),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => PayZakatPage()),
        icon: const Icon(Icons.payment),
        label: const Text('Pay Zakat'),
        tooltip: 'Pay Zakat',
        elevation: 4,
      ),
    );
  }

  Widget _buildSummarySection(BuildContext context) {
    // Calculate total Zakat paid
    final totalPaid = zakatController.zakatHistory
        .fold<double>(0, (sum, payment) => sum + payment.amount);

    // Get payment count
    final paymentCount = zakatController.zakatHistory.length;

    // Get latest payment date
    final latestPayment = zakatController.zakatHistory.isNotEmpty
        ? zakatController.zakatHistory[0]
        : null;
    final dateFormat = DateFormat('MMMM d, yyyy');
    final latestDate = latestPayment != null
        ? dateFormat.format(latestPayment.paymentDate)
        : 'N/A';

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                context,
                'Total Paid',
                '${totalPaid.toStringAsFixed(1)} ${zakatController.preferedAmount}',
                Icons.account_balance_wallet,
                Colors.green,
              ),
              _buildSummaryItem(
                context,
                'Payments',
                paymentCount.toString(),
                Icons.receipt_long,
                Colors.blue,
              ),
              _buildSummaryItem(
                context,
                'Latest Payment',
                latestDate,
                Icons.calendar_today,
                Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(BuildContext context, ZakatPaymentModel payment) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final currencyFormat =
        NumberFormat.currency(symbol: '${zakatController.preferedAmount} ');

    // Calculate days since payment
    final daysSincePayment =
        DateTime.now().difference(payment.paymentDate).inDays;
    String timeAgo;

    if (daysSincePayment == 0) {
      timeAgo = 'Today';
    } else if (daysSincePayment == 1) {
      timeAgo = 'Yesterday';
    } else if (daysSincePayment < 30) {
      timeAgo = '$daysSincePayment days ago';
    } else {
      timeAgo = dateFormat.format(payment.paymentDate);
    }

    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showFullPaymentDetails(context, payment),
        child: Column(
          children: [
            // Header with date and amount
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 16, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(payment.paymentDate),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      timeAgo,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              alignment: Alignment(0, 0),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                currencyFormat.format(payment.amount),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),
            // Payment details
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notes section
                  if (payment.notes.isNotEmpty) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.note, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            payment.notes,
                            style: TextStyle(color: Colors.grey[700]),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Asset and Income counts
                  Row(
                    children: [
                      // Assets pill
                      Expanded(
                        child: _buildDetailSection(
                          context: context,
                          title: 'Assets',
                          count: payment.assetIds.length,
                          icon: Icons.account_balance_wallet,
                          color: Colors.blue,
                          onTap: () => _showPaymentDetailsDialog(
                            context,
                            payment,
                            'assets',
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      // Income pill
                      Expanded(
                        child: _buildDetailSection(
                          context: context,
                          title: 'Income',
                          count: payment.incomeIds.length,
                          icon: Icons.trending_up,
                          color: Colors.orange,
                          onTap: () => _showPaymentDetailsDialog(
                            context,
                            payment,
                            'income',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required BuildContext context,
    required String title,
    required int count,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: count > 0 ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: count > 0 ? color.withOpacity(0.1) : Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: count > 0
              ? Border.all(color: color.withOpacity(0.3), width: 1)
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: count > 0 ? color : Colors.grey),
            const SizedBox(width: 8),
            Text(
              '$title: $count',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: count > 0 ? color : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFullPaymentDetails(
    BuildContext context,
    ZakatPaymentModel payment,
  ) {
    final dateFormat = DateFormat('MMMM d, yyyy');
    final currencyFormat =
        NumberFormat.currency(symbol: '${zakatController.preferedAmount} ');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header with drag indicator

                    const SizedBox(height: 16),

                    // Title
                    const Center(
                      child: Text(
                        'Payment Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment amount
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          currencyFormat.format(payment.amount),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Payment date
                    _buildDetailRow(
                      'Payment Date',
                      dateFormat.format(payment.paymentDate),
                      Icons.calendar_today,
                    ),
                    const Divider(height: 24),

                    // Notes
                    if (payment.notes.isNotEmpty) ...[
                      _buildDetailRow(
                        'Notes',
                        payment.notes,
                        Icons.note,
                      ),
                      const Divider(height: 24),
                    ],

                    // Assets section
                    const Text(
                      'Assets Included',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (payment.assetIds.isEmpty)
                      const Text('No assets included in this payment'),

                    if (payment.assetIds.isNotEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${payment.assetIds.length} Assets',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showPaymentDetailsDialog(
                                  context,
                                  payment,
                                  'assets',
                                ),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('View Assets'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Income section
                    const Text(
                      'Income Included',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (payment.incomeIds.isEmpty)
                      const Text('No income included in this payment'),

                    if (payment.incomeIds.isNotEmpty)
                      Card(
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${payment.incomeIds.length} Income Sources',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ElevatedButton.icon(
                                onPressed: () => _showPaymentDetailsDialog(
                                  context,
                                  payment,
                                  'income',
                                ),
                                icon: const Icon(Icons.visibility, size: 16),
                                label: const Text('View Income'),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPaymentDetailsDialog(
    BuildContext context,
    ZakatPaymentModel payment,
    String type,
  ) {
    List<String> ids = type == 'assets' ? payment.assetIds : payment.incomeIds;
    final assetController = Get.find<AssetController>();
    // Assuming you have an IncomeController similar to AssetController
    // final incomeController = Get.find<IncomeController>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      type == 'assets'
                          ? Icons.account_balance_wallet
                          : Icons.trending_up,
                      color: type == 'assets' ? Colors.blue : Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${type.capitalize} Details',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                Expanded(
                  child: type == 'assets'
                      ? _buildAssetsList(assetController, ids)
                      : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.construction,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              const Text('Income details coming soon'),
                            ],
                          ),
                        ),
                  // Replace with _buildIncomeList(incomeController, ids)
                ),
                const Divider(),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAssetsList(
      AssetController assetController, List<String> assetIds) {
    // Filter assets by IDs
    List<AssetModel> paymentAssets = assetController.assets
        .where((asset) => assetIds.contains(asset.id))
        .toList();

    if (paymentAssets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Asset information no longer available',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: paymentAssets.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final asset = paymentAssets[index];
        final currencyFormat = NumberFormat.currency(symbol: '\$');

        // Generate a color based on asset type
        final Color assetColor = _getColorForAssetType(asset.assetType);

        return ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(
            backgroundColor: assetColor.withOpacity(0.2),
            child: Icon(_getIconForAssetType(asset.assetType),
                color: assetColor, size: 20),
          ),
          title: Text(
            asset.assetName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(asset.assetType),
          trailing: Text(
            currencyFormat.format(asset.totalValue),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  IconData _getIconForAssetType(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'gold':
      case 'silver':
      case 'jewelry':
        return Icons.diamond;
      case 'cash':
      case 'money':
      case 'currency':
        return Icons.attach_money;
      case 'stocks':
      case 'investments':
        return Icons.trending_up;
      case 'property':
      case 'real estate':
        return Icons.home;
      case 'business':
        return Icons.business;
      case 'crypto':
      case 'cryptocurrency':
        return Icons.currency_bitcoin;
      default:
        return Icons.account_balance_wallet;
    }
  }

  Color _getColorForAssetType(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'gold':
      case 'jewelry':
        return Colors.amber;
      case 'silver':
        return Colors.blueGrey;
      case 'cash':
      case 'money':
      case 'currency':
        return Colors.green;
      case 'stocks':
      case 'investments':
        return Colors.blue;
      case 'property':
      case 'real estate':
        return Colors.brown;
      case 'business':
        return Colors.purple;
      case 'crypto':
      case 'cryptocurrency':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}

// Extension method to capitalize the first letter of a string
