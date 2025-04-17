import 'package:finance/Features/Income/Presentation/Controllers/income_controller.dart';
import 'package:finance/Features/zakat/Presentation/Screens/payzakat_page.dart';
import 'package:finance/Features/zakat/Presentation/Screens/zakat_history_page.dart';
import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:finance/Features/zakat/Presentation/controller/zakat_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ZakatCalculationPage extends StatelessWidget {
  ZakatCalculationPage({super.key});

  final ZakatController controller = Get.put(ZakatController());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zakat Calculation',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showZakatInfo(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.calculateZakat,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Zakat Summary Card with visual indicator
                    _buildZakatSummaryCard(context),

                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(context),

                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                      child: Text(
                        'Zakatable Assets',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Zakatable Assets List
              _buildZakatableItemsList(),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.calculateZakat(),
        tooltip: 'Recalculate Zakat',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildZakatSummaryCard(BuildContext context) {
    final totalDue = controller.totalZakatDue.value;
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Color(0xFF003161),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: Row(
              children: [
                Icon(Icons.account_balance, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Text(
                  'Zakat Summary',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white30, thickness: 1, height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildSummaryRow(
                  'Zakatable Assets',
                  '${controller.totalZakatableAssets.value.toStringAsFixed(0)} ${controller.preferedAmount}',
                  textColor: Colors.white,
                ),
                const SizedBox(height: 8),
                _buildSummaryRow(
                  'Zakatable Income',
                  '${controller.totalZakatableIncome.value.toStringAsFixed(0)} ${controller.preferedAmount}',
                  textColor: Colors.white,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child:
                      Divider(color: Colors.white30, thickness: 1, height: 1),
                ),
                _buildSummaryRow(
                  'Total Zakat Due (2.5%)',
                  '${totalDue.toStringAsFixed(0)} ${controller.preferedAmount}',
                  textColor: Colors.white,
                  isBold: true,
                  fontSize: 15,
                ),
              ],
            ),
          ),

          // Visual indicator of zakat payment status
          Container(
            margin: const EdgeInsets.only(top: 20),
            height: 40,
            decoration: const BoxDecoration(
              color: Colors.white10,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Center(
              child: Text(
                totalDue > 0 ? 'Zakat payment pending' : 'Zakat up to date',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => Get.to(() => PayZakatPage()),
              icon: const Icon(Icons.payment),
              label: const Text('Pay Zakat'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Get.to(() => ZakatHistoryPage()),
              icon: const Icon(Icons.history),
              label: const Text('View History'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isBold = false, Color? textColor, double? fontSize}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w400,
            color: textColor ?? Colors.black,
            fontSize: fontSize ?? 16,
          ),
        ),
        SizedBox(
          width: 85,
          child: Text(
            value,
            style: TextStyle(
              overflow: TextOverflow.fade,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textColor ?? Colors.black,
              fontSize: fontSize ?? 16,
            ),
          ),
        ),
      ],
    );
  }

  SliverList _buildZakatableItemsList() {
    final assetController = Get.find<AssetController>();
    final incomeController = Get.find<IncomeController>();

    List<Widget> items = [];

    // Add assets
    for (var asset in assetController.assets) {
      if (asset.isZakatable && !asset.zakatIsPaid) {
        items.add(_buildAssetListItem(asset));
      }
    }

    // Add income entries
    for (var income in incomeController.incomeEntries) {
      if (!income['zakatIsPaid'] && income['amount'] > 135000) {
        items.add(_buildIncomeListItem(income));
      }
    }

    if (items.isEmpty) {
      items.add(
        const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'No zakatable assets or income found',
              style: TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildListDelegate(items),
    );
  }

  Widget _buildAssetListItem(dynamic asset) {
    IconData iconData;
    Color iconColor;

    switch (asset.assetType.toLowerCase()) {
      case 'gold':
      case 'silver':
        iconData = Icons.diamond;
        iconColor = Colors.amber;
        break;
      case 'cash':
      case 'bank account':
        iconData = Icons.account_balance_wallet;
        iconColor = Colors.green;
        break;
      case 'investment':
      case 'stock':
        iconData = Icons.trending_up;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.inventory;
        iconColor = Colors.purple;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: iconColor.withOpacity(0.1),
          child: Icon(iconData, color: iconColor),
        ),
        title: Text(
          asset.assetName,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(asset.assetType),
            const SizedBox(height: 2),
            Text(
              '${asset.totalValue.toStringAsFixed(1)} ${controller.preferedAmount}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle asset details view
        },
      ),
    );
  }

  Widget _buildIncomeListItem(Map<String, dynamic> income) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundColor: Colors.blueGrey,
          child: Icon(Icons.attach_money, color: Colors.white),
        ),
        title: Text(
          income['sourceName'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const Text('Income'),
            const SizedBox(height: 2),
            Text(
              '${(income['amount'] as double).toStringAsFixed(1)} ${controller.preferedAmount}',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {
          // Handle income details view
        },
      ),
    );
  }

  void _showZakatInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              const Text(
                'About Zakat',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Zakat is one of the Five Pillars of Islam and is a form of obligatory charitable giving. '
                'It is calculated as 2.5% of wealth that has been held for one lunar year.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const Text(
                'Zakat is due on assets that meet the nisab threshold (minimum amount). '
                'This app uses current market rates for gold and silver to determine the nisab threshold.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(
                'Eligible Assets',
                'Gold, silver, cash, savings, business inventory, investments, and other wealth that has been held for one lunar year.',
                Icons.account_balance_wallet,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Current Nisab Threshold',
                'The app automatically calculates the nisab threshold based on current gold and silver prices.',
                Icons.attach_money,
              ),
              const SizedBox(height: 16),
              _buildInfoCard(
                'Calculation Method',
                'The app uses the standard rate of 2.5% on all zakatable assets and income that meet the nisab threshold.',
                Icons.calculate,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(String title, String content, IconData icon) {
    return Card(
      elevation: 0,
      color: Color(0xFF006A67),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.grey[100]),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: TextStyle(
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
