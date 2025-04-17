import 'package:finance/Features/stocks/Data/stock_data_source.dart';
import 'package:finance/Features/stocks/Data/stocks_asset.dart';
import 'package:finance/Features/stocks/Presentation/Controllers/stock_asset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddAssetScreen extends StatelessWidget {
  final StockAssetController controller = Get.find<StockAssetController>();
  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final quantityController = TextEditingController();

  final RxString selectedType = 'crypto'.obs;
  final assetTypes = ['crypto'];

  AddAssetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Asset')),
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
              // Obx(() => DropdownButtonFormField<String>(
              //       value: selectedType.value,
              //       items: assetTypes.map((type) {
              //         return DropdownMenuItem(
              //           value: type,
              //           child: Text(type.capitalize!),
              //         );
              //       }).toList(),
              //       onChanged: (value) => selectedType.value = value!,
              //       decoration: InputDecoration(
              //         border: OutlineInputBorder(),
              //       ),
              //     )),
              SizedBox(height: 16),

              // Name/Symbol field
              Autocomplete<Cryptocurrency>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return cryptocurrencies;
                  }
                  return cryptocurrencies.where((Cryptocurrency option) {
                    return option.name
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase()) ||
                        option.symbol
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                  });
                },
                displayStringForOption: (Cryptocurrency option) =>
                    '${option.name} (${option.symbol})',
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  return TextFormField(
                    controller: fieldTextEditingController,
                    focusNode: fieldFocusNode,
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
                    onFieldSubmitted: (String value) {
                      onFieldSubmitted();
                    },
                  );
                },
                onSelected: (Cryptocurrency selection) {
                  // Store only the symbol in the nameController
                  nameController.text = selection.name;

                  // Optional: You might want to unfocus after selection
                  FocusScope.of(context).unfocus();
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
                child: Text('Add Asset'),
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
      final asset = Asset(
        id: '', // Firebase will generate this
        name: nameController.text.trim(),
        assetType: selectedType.value,
        purchasePrice: double.parse(priceController.text),
        quantity: double.parse(quantityController.text),
        purchaseDate: DateTime.now(),
        userId: Get.find<FirebaseService>().currentUserId,
      );

      final success = await controller.addAsset(asset);
      if (success) {
        Get.back();
        Get.snackbar('Success', 'Asset added successfully');
      } else {
        Get.snackbar('Error', 'Failed to add asset. Please try again.');
      }
    }
  }
}

// Define the Cryptocurrency class
// Define the Cryptocurrency class
class Cryptocurrency {
  final String name;
  final String symbol;

  Cryptocurrency({required this.name, required this.symbol});
}

// Create the list of cryptocurrencies from the image
final List<Cryptocurrency> cryptocurrencies = [
  Cryptocurrency(name: 'Bitcoin', symbol: 'BTC'),
  Cryptocurrency(name: 'Ethereum', symbol: 'ETH'),
  Cryptocurrency(name: 'Ripple', symbol: 'XRP'),
  Cryptocurrency(name: 'Litecoin', symbol: 'LTC'),
  Cryptocurrency(name: 'Dogecoin', symbol: 'DOGE'),
  Cryptocurrency(name: 'Cardano', symbol: 'ADA'),
];

// Using the correct casing for the Autocomplete widget
