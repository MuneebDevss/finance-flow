import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Features/stocks/Data/stocks_asset.dart';
import 'package:finance/Features/stocks/Presentation/Controllers/stock_asset_controller.dart';
import 'package:finance/Features/stocks/Presentation/Screens/add_asset_screen.dart';
import 'package:finance/Features/stocks/Presentation/Screens/asset_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetListScreen extends StatelessWidget {
  final StockAssetController controller = Get.put(StockAssetController());

  AssetListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigationWidget(6),
      appBar: AppBar(
        title: const Text(
          'My Portfolio',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [
          Obx(() => controller.isRefreshing.value
              ? Container(
                  margin: const EdgeInsets.all(14),
                  width: 24,
                  height: 24,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Refresh Prices',
                  onPressed: () => controller.refreshPrices(),
                )),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => controller.refreshPrices(),
        child: Column(
          children: [
            // Portfolio summary card
            _buildSummaryCard(),

            // Asset list
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Loading your assets...'),
                      ],
                    ),
                  );
                }

                if (controller.assets.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Your portfolio is empty',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add your first asset to get started',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Add Asset'),
                          onPressed: () => Get.to(() => AddAssetScreen()),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 80),
                  itemCount: controller.assets.length,
                  itemBuilder: (context, index) {
                    final asset = controller.assets[index];
                    return _buildAssetCard(asset, context);
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Add Asset'),
        onPressed: () => Get.to(() => AddAssetScreen()),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Obx(() {
      final totalValue = controller.getTotalPortfolioValue();
      final totalInvestment = controller.getTotalInvestment();
      final profitLoss = controller.getTotalProfitLoss();
      final returnPercentage = controller.getTotalReturnPercentage();

      return Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade800, Colors.blue.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              blurRadius: 10,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Portfolio Summary',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white70,
                        ),
                      ),
                      Icon(Icons.analytics_outlined, color: Colors.white70),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${totalValue.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        profitLoss >= 0
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                        color: profitLoss >= 0
                            ? Colors.green.shade200
                            : Colors.red.shade200,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '\$${profitLoss.abs().toStringAsFixed(2)} (${returnPercentage.abs().toStringAsFixed(2)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          color: profitLoss >= 0
                              ? Colors.green.shade200
                              : Colors.red.shade200,
                        ),
                      ),
                      const Text(
                        ' overall',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildSummaryItem(
                      'Invested', '\$${totalInvestment.toStringAsFixed(2)}'),
                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(color: Colors.white30, thickness: 1),
                  ),
                  _buildSummaryItem(
                    'Day Change',
                    '+\$24.82 (0.75%)',
                    positive: true,
                  ),
                  const SizedBox(
                    height: 24,
                    child: VerticalDivider(color: Colors.white30, thickness: 1),
                  ),
                  _buildSummaryItem('Assets', '${controller.assets.length}'),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSummaryItem(String label, String value, {bool? positive}) {
    Color valueColor = Colors.white;
    if (positive != null) {
      valueColor = positive ? Colors.green.shade200 : Colors.red.shade200;
    }

    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildAssetCard(Asset asset, BuildContext context) {
    final profitColor = asset.profitLoss >= 0 ? Colors.green : Colors.red;
    final isProfitable = asset.profitLoss >= 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Get.to(() => AssetDetailScreen(asset: asset)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  // Asset icon or logo
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: _getAssetIcon(asset.assetType),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Asset details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          asset.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${asset.quantity.toString()} ${asset.assetType} • Avg \$${asset.purchasePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Current price and change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '\$${asset.currentPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isProfitable
                              ? Colors.green.shade50
                              : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isProfitable
                                  ? Icons.arrow_upward
                                  : Icons.arrow_downward,
                              size: 12,
                              color: profitColor,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${asset.returnPercentage.abs().toStringAsFixed(2)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: profitColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Asset value bar
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Value: \$${(asset.currentPrice * asset.quantity).toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 13),
                      ),
                      Text(
                        'P/L: ${isProfitable ? "+" : ""}\$${asset.profitLoss.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: profitColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: 0.5, // Replace with actual allocation percentage
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _getAssetColor(asset.assetType),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getAssetIcon(String assetType) {
    IconData iconData;

    switch (assetType.toLowerCase()) {
      case 'stock':
        iconData = Icons.show_chart;
        break;
      case 'crypto':
        iconData = Icons.currency_bitcoin;
        break;
      case 'etf':
        iconData = Icons.bar_chart;
        break;
      case 'bond':
        iconData = Icons.account_balance;
        break;
      default:
        iconData = Icons.monetization_on;
    }

    return Icon(iconData, color: _getAssetColor(assetType));
  }

  Color _getAssetColor(String assetType) {
    switch (assetType.toLowerCase()) {
      case 'stock':
        return Colors.blue;
      case 'crypto':
        return Colors.orange;
      default:
        return Colors.teal;
    }
  }
}
