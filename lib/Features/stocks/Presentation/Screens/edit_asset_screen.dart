import 'package:finance/Features/stocks/Data/stocks_asset.dart';
import 'package:finance/Features/stocks/Presentation/Controllers/stock_asset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditAssetScreen extends StatelessWidget {
  final Asset asset;
  final StockAssetController controller = Get.find<StockAssetController>();
  final formKey = GlobalKey<FormState>();
  
  late final nameController = TextEditingController(text: asset.name);
  late final priceController = TextEditingController(text: asset.purchasePrice.toString());
  late final quantityController = TextEditingController(text: asset.quantity.toString());
  late final RxString selectedType = asset.assetType.obs;
  
  final assetTypes = ['stock', 'mutualFund', 'realEstate', 'crypto', 'other'];
  
  EditAssetScreen({required this.asset});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit ${asset.name}')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Asset type dropdown
              Text('Asset Type', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Obx(() => DropdownButtonFormField<String>(
                value: selectedType.value,
                items: assetTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type.capitalize!),
                  );
                }).toList(),
                onChanged: (value) => selectedType.value = value!,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
              )),
              SizedBox(height: 16),
              
              // Name/Symbol field
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Asset Name/Symbol',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter asset name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Purchase price field
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(
                  labelText: 'Purchase Price (\$)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter purchase price';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              
              // Quantity field
              TextFormField(
                controller: quantityController,
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter quantity';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              
              // Submit button
              ElevatedButton(
                onPressed: () => _submitForm(),
                child: Text('Update Asset'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _submitForm() async {
    if (formKey.currentState!.validate()) {
      final updatedAsset = Asset(
        id: asset.id,
        name: nameController.text.trim(),
        assetType: selectedType.value,
        purchasePrice: double.parse(priceController.text),
        currentPrice: asset.currentPrice, // Keep current price
        quantity: double.parse(quantityController.text),
        purchaseDate: asset.purchaseDate, // Keep purchase date
        userId: asset.userId,
        additionalInfo: asset.additionalInfo,
      );
      
      final success = await controller.updateAsset(updatedAsset);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Asset updated successfully');
      } else {
        Get.snackbar('Error', 'Failed to update asset. Please try again.');
      }
    }
  }
}