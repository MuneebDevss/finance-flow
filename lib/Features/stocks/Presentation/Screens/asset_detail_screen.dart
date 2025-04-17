import 'package:finance/Features/stocks/Data/stocks_asset.dart';
import 'package:finance/Features/stocks/Presentation/Controllers/stock_asset_controller.dart';
import 'package:finance/Features/stocks/Presentation/Screens/edit_asset_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AssetDetailScreen extends StatelessWidget {
  final Asset asset;
  final StockAssetController controller = Get.find<StockAssetController>();
  
  AssetDetailScreen({super.key, required this.asset});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(asset.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => Get.to(() => EditAssetScreen(asset: asset)),
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildDetailRow('Asset Type', asset.assetType.capitalize!),
                    _buildDetailRow('Current Price', '\$${asset.currentPrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Purchase Price', '\$${asset.purchasePrice.toStringAsFixed(2)}'),
                    _buildDetailRow('Quantity', asset.quantity.toString()),
                    _buildDetailRow('Purchase Date', _formatDate(asset.purchaseDate)),
                    Divider(),
                    _buildDetailRow('Total Value', '\$${asset.currentValue.toStringAsFixed(2)}'),
                    _buildDetailRow('Total Invested', '\$${asset.totalInvestment.toStringAsFixed(2)}'),
                    _buildDetailRow(
                      'Profit/Loss', 
                      '\$${asset.profitLoss.toStringAsFixed(2)}',
                      asset.profitLoss >= 0 ? Colors.green : Colors.red
                    ),
                    _buildDetailRow(
                      'Return', 
                      '${asset.returnPercentage.toStringAsFixed(2)}%',
                      asset.returnPercentage >= 0 ? Colors.green : Colors.red
                    ),
                  ],
                ),
              ),
            ),
            
            // Additional info section if any
            if (asset.additionalInfo.isNotEmpty) ...[
              SizedBox(height: 16),
              Text('Additional Info', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    children: asset.additionalInfo.entries.map((entry) {
                      return _buildDetailRow(entry.key, entry.value.toString());
                    }).toList(),
                  ),
                ),
              ),
            ],
            
            SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: Icon(Icons.refresh),
                label: Text('Refresh Price'),
                onPressed: () async {
                  await controller.refreshPrices();
                  Get.snackbar('Updated', 'Asset price refreshed');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDetailRow(String label, String value, [Color? valueColor]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          Text(
            value,
            style: TextStyle(color: valueColor),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
  
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Asset'),
        content: Text('Are you sure you want to delete ${asset.name}?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete', style: TextStyle(color: Colors.red)),
            onPressed: () async {
              Navigator.pop(context);
              final success = await controller.deleteAsset(asset.id);
              if (success) {
                Get.back();
                Get.snackbar('Deleted', 'Asset deleted successfully');
              } else {
                Get.snackbar('Error', 'Failed to delete asset');
              }
            },
          ),
        ],
      ),
    );
  }
}