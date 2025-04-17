import 'package:finance/Features/zakat/Presentation/Screens/add_assets_page.dart';
import 'package:finance/Features/zakat/Presentation/Screens/asset_details_page.dart';
import 'package:finance/Features/zakat/Presentation/Screens/edit_assets_page.dart';
import 'package:finance/Features/zakat/Presentation/Screens/zakat_calulation_page.dart';
import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:finance/Features/zakat/data/model/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetManagementPage extends StatelessWidget {
  final AssetController controller = Get.put(AssetController());

  AssetManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Asset Management',
            style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          Tooltip(
            message: 'Calculate Zakat',
            child: IconButton(
              icon: const Icon(Icons.calculate),
              onPressed: () => Get.to(() => ZakatCalculationPage()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(),
        child: Obx(() {
          if (controller.isLoading.value && controller.assets.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (controller.assets.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/empty_state.png', // Add an empty state illustration
                    height: 150,
                    width: 150,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No assets added yet',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Start tracking your assets for Zakat calculation',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () => Get.to(() => AddAssetPage()),
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text('Add Your First Asset'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
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
              // Summary card
              AssetSummaryCard(controller: controller),
              // Assets list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: controller.fetchAssets,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.assets.length,
                    itemBuilder: (context, index) {
                      final asset = controller.assets[index];
                      return AssetListItem(asset: asset);
                    },
                  ),
                ),
              ),
            ],
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => AddAssetPage()),
        icon: const Icon(Icons.add),
        label: const Text('New Asset'),
        elevation: 4,
      ),
    );
  }
}

class AssetSummaryCard extends StatelessWidget {
  final AssetController controller;

  const AssetSummaryCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final totalAssetValue = controller.assets
        .fold<double>(0, (sum, asset) => sum + asset.totalValue);
    final zakatableAssets =
        controller.assets.where((a) => a.isZakatable).toList();
    final totalZakatableValue =
        zakatableAssets.fold<double>(0, (sum, asset) => sum + asset.totalValue);
    final zakatAmount =
        totalZakatableValue * 0.025; // 2.5% is standard zakat rate

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Assets Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildSummaryItem(
                context,
                'Total Assets',
                '${controller.assets.length}',
                Icons.account_balance_wallet,
                Colors.blue,
              ),
              _buildSummaryItem(
                context,
                'Total Value',
                '${totalAssetValue.toStringAsFixed(1)} ${controller.preferedAmount}',
                Icons.attach_money,
                Colors.green,
              ),
              _buildSummaryItem(
                context,
                'Zakat Due',
                '${zakatAmount.toStringAsFixed(2)} ${controller.preferedAmount}',
                Icons.calendar_today,
                Colors.orange,
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
          ),
        ],
      ),
    );
  }
}

class AssetListItem extends StatelessWidget {
  final AssetModel asset;
  final AssetController controller = Get.find<AssetController>();

  AssetListItem({required this.asset});

  @override
  Widget build(BuildContext context) {
    // Generate a color based on asset type for the avatar
    final Color avatarColor = _getColorForAssetType(asset.assetType);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Get.to(() => AssetDetailsPage(asset: asset));
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Asset type icon
              CircleAvatar(
                backgroundColor: avatarColor.withOpacity(0.2),
                radius: 24,
                child: Icon(_getIconForAssetType(asset.assetType),
                    color: avatarColor),
              ),
              const SizedBox(width: 12),
              // Asset details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      asset.assetName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${asset.assetType} • ${asset.quantity.toStringAsFixed(asset.quantity.truncateToDouble() == asset.quantity ? 0 : 2)} units',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${asset.totalValue.toStringAsFixed(1)} ${controller.preferedAmount}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const Spacer(),
                        // Zakat status badges
                        if (asset.isZakatable)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: asset.zakatIsPaid
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  asset.zakatIsPaid
                                      ? Icons.check_circle
                                      : Icons.pending,
                                  size: 14,
                                  color: asset.zakatIsPaid
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  asset.zakatIsPaid ? 'Paid' : 'Due',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: asset.zakatIsPaid
                                        ? Colors.green
                                        : Colors.orange,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(
                                  Icons.cancel,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Not Applicable',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions menu
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'edit') {
                    controller.loadAssetForEdit(asset);
                    Get.to(() => EditAssetPage(assetId: asset.id));
                  } else if (value == 'delete') {
                    _showDeleteConfirmationDialog(context, asset);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit Asset')),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete Asset',
                        style: TextStyle(color: Colors.red)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, AssetModel asset) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Asset'),
        content: Text('Are you sure you want to delete "${asset.assetName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteAsset(asset.id);
            },
            icon: const Icon(Icons.delete),
            label: const Text('Delete'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
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
