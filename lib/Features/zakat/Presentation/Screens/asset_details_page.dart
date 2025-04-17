import 'package:finance/Features/zakat/Presentation/Screens/edit_assets_page.dart';
import 'package:finance/Features/zakat/Presentation/Screens/payzakat_page.dart';
import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:finance/Features/zakat/data/model/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AssetDetailsPage extends StatelessWidget {
  final AssetModel asset;
  final AssetController assetController = Get.find<AssetController>();

  AssetDetailsPage({required this.asset});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asset Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
              assetController.loadAssetForEdit(asset);
              Get.to(() => EditAssetPage(assetId: asset.id));
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Asset Header
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: _getAssetTypeColor(asset.assetType),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        _getAssetTypeIcon(asset.assetType),
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.assetName,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        asset.assetType,
                        style: TextStyle(
                            fontSize: 16, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Value Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Value Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    _buildDetailRow('Value per Unit',
                        '${assetController.preferedAmount} ${asset.value.toStringAsFixed(2)}'),
                    _buildDetailRow(
                        'Quantity',
                        asset.quantity.toStringAsFixed(
                            asset.quantity.truncateToDouble() == asset.quantity
                                ? 0
                                : 2)),
                    Divider(),
                    _buildDetailRow('Total Value',
                        '${assetController.preferedAmount} ${asset.totalValue.toStringAsFixed(2)}',
                        isBold: true),
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Zakat Information
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Zakat Status',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          asset.isZakatable ? Icons.check_circle : Icons.cancel,
                          color: asset.isZakatable ? Colors.green : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(
                          asset.isZakatable
                              ? 'Zakatable Asset'
                              : 'Not Zakatable',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    if (asset.isZakatable) ...[
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            asset.zakatIsPaid
                                ? Icons.check_circle
                                : Icons.pending_actions,
                            color: asset.zakatIsPaid
                                ? Colors.green
                                : Colors.orange,
                          ),
                          SizedBox(width: 8),
                          Text(
                            asset.zakatIsPaid ? 'Zakat Paid' : 'Zakat Due',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (asset.zakatIsPaid) ...[
                        SizedBox(height: 8),
                        Text(
                          'Zakat Amount: ${assetController.preferedAmount} ${(asset.totalValue * 0.025).toStringAsFixed(2)} (2.5%)',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ),

            SizedBox(height: 16),

            // Additional Details
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Additional Information',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    _buildDetailRow(
                        'Acquisition Date',
                        DateFormat('MMMM d, yyyy')
                            .format(asset.acquisitionDate)),
                    if (asset.notes.isNotEmpty)
                      _buildDetailRow('Notes', asset.notes),
                    _buildDetailRow(
                        'Date Added',
                        asset.createdAt != null
                            ? DateFormat('MMMM d, yyyy')
                                .format(asset.createdAt!)
                            : 'N/A'),
                    if (asset.updatedAt != null)
                      _buildDetailRow('Last Updated',
                          DateFormat('MMMM d, yyyy').format(asset.updatedAt!)),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (asset.isZakatable && !asset.zakatIsPaid)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to pay zakat page with this asset pre-selected
                        Get.to(
                            () => PayZakatPage(selectedAssetIds: [asset.id]));
                      },
                      icon: Icon(Icons.payment),
                      label: Text('Pay Zakat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Delete Asset'),
                          content: Text(
                              'Are you sure you want to delete this asset?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                assetController.deleteAsset(asset.id);
                                Get.back();
                              },
                              style: TextButton.styleFrom(
                                  foregroundColor: Colors.red),
                              child: Text('Delete'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(Icons.delete),
                    label: Text('Delete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getAssetTypeColor(String assetType) {
    switch (assetType) {
      case 'Gold':
        return Colors.amber;
      case 'Silver':
        return Colors.blueGrey;
      case 'Cash':
        return Colors.green;
      case 'Investments':
        return Colors.blue;
      case 'Property':
        return Colors.brown;
      default:
        return Colors.purple;
    }
  }

  IconData _getAssetTypeIcon(String assetType) {
    switch (assetType) {
      case 'Gold':
        return Icons.monetization_on;
      case 'Silver':
        return Icons.monetization_on;
      case 'Cash':
        return Icons.account_balance_wallet;
      case 'Investments':
        return Icons.trending_up;
      case 'Property':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
