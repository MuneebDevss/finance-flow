import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Features/Income/Presentation/Controllers/income_controller.dart';
import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:finance/Features/zakat/Presentation/controller/zakat_controller.dart';
import 'package:finance/Features/zakat/data/model/assets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayZakatPage extends StatefulWidget {
  final List<String> selectedAssetIds;

  const PayZakatPage({super.key, this.selectedAssetIds = const []});

  @override
  State<PayZakatPage> createState() => _PayZakatPageState();
}

class _PayZakatPageState extends State<PayZakatPage> {
  final ZakatController zakatController = Get.put(ZakatController());

  final AssetController assetController = Get.find<AssetController>();

  final IncomeController incomeController = Get.find<IncomeController>();

  // Form controllers
  final TextEditingController amountController = TextEditingController();

  final TextEditingController notesController = TextEditingController();

  // Track selected items
  final RxList<String> selectedAssets = <String>[].obs;

  final RxList<String> selectedIncomes = <String>[].obs;

  @override
  void initState() {
    super.initState();
    // Add any pre-selected assets
    selectedAssets.addAll(widget.selectedAssetIds);

    // Set default amount to total zakat due
    amountController.text =
        zakatController.totalZakatDue.value.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    // Initialize pre-selected assets
    if (selectedAssets.isEmpty && widget.selectedAssetIds.isNotEmpty) {
      selectedAssets.addAll(widget.selectedAssetIds);
      // Set amount to the pre-selected assets' zakat amount
      double preSelectedAmount = 0;
      for (var asset in assetController.assets) {
        if (widget.selectedAssetIds.contains(asset.id)) {
          preSelectedAmount += asset.totalValue * 0.025;
        }
      }
      amountController.text = preSelectedAmount.toStringAsFixed(2);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Pay Zakat'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Payment Amount
            Text('Payment Amount',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Amount to Pay*',
                hintText: 'Enter amount',
                border: OutlineInputBorder(),
                prefixText: '${zakatController.preferedAmount} ',
              ),
            ),
            SizedBox(height: 16),

            // Select Assets
            Text('Select Assets for Zakat Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Card(
              child: Obx(() {
                List<AssetModel> zakatableAssets = assetController.assets
                    .where((asset) => asset.isZakatable && !asset.zakatIsPaid)
                    .toList();

                if (zakatableAssets.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No zakatable assets available'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: zakatableAssets.length,
                  itemBuilder: (context, index) {
                    final asset = zakatableAssets[index];
                    return CheckboxListTile(
                      title: Text(asset.assetName),
                      subtitle: Text(
                          '${asset.assetType} • ${asset.totalValue.toStringAsFixed(1)} ${zakatController.preferedAmount} • Zakat: ${(asset.totalValue * 0.025).toStringAsFixed(1)} ${zakatController.preferedAmount}'),
                      value: selectedAssets.contains(asset.id),
                      onChanged: (bool? value) {
                        if (value == true) {
                          selectedAssets.add(asset.id);
                        } else {
                          selectedAssets.remove(asset.id);
                        }
                        _updateTotalAmount();
                        setState(() {});
                      },
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 16),

            // Select Income Entries
            Text('Select Income for Zakat Payment',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            Card(
              child: Obx(() {
                List<Map<String, dynamic>> zakatableIncomes = incomeController
                    .incomeEntries
                    .where((income) =>
                        !income['zakatIsPaid'] && income['amount'] > 135000)
                    .toList();

                if (zakatableIncomes.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No zakatable income entries available'),
                  );
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: zakatableIncomes.length,
                  itemBuilder: (context, index) {
                    final income = zakatableIncomes[index];
                    return CheckboxListTile(
                      title: Text(income['sourceName']),
                      subtitle: Text(
                          '${income['category']} • ${income['amount'].toStringAsFixed(1)} ${zakatController.preferedAmount} • Zakat: ${(income['amount'] * 0.025).toStringAsFixed(1)} ${zakatController.preferedAmount}'),
                      value: selectedIncomes.contains(income['id']),
                      onChanged: (bool? value) {
                        if (value == true) {
                          selectedIncomes.add(income['id']);
                        } else {
                          selectedIncomes.remove(income['id']);
                        }
                        _updateTotalAmount();
                        setState(() {});
                      },
                    );
                  },
                );
              }),
            ),
            SizedBox(height: 16),

            // Notes
            Text('Payment Notes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 8),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any details about this payment',
                border: OutlineInputBorder(),
              ),
            ),

            SizedBox(height: 24),

            // Pay Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (_validateForm()) {
                    double amount = double.tryParse(amountController.text) ?? 0;
                    zakatController.recordZakatPayment(
                      amount,
                      selectedAssets.toList(),
                      selectedIncomes.toList(),
                      notesController.text,
                    );
                    Get.back();
                  }
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 64, vertical: 16),
                  textStyle: TextStyle(fontSize: 18),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Complete Payment'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validateForm() {
    if (amountController.text.isEmpty) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Please enter a payment amount");
      return false;
    }

    double amount = double.tryParse(amountController.text) ?? 0;
    if (amount <= 0) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Amount must be greater than zero");
      return false;
    }

    if (selectedAssets.isEmpty && selectedIncomes.isEmpty) {
      HelpingFunctions.showSnackBar(
          Get.context!, "Please select at least one asset or income entry");
      return false;
    }

    return true;
  }

  void _updateTotalAmount() {
    double total = 0;

    // Calculate from selected assets
    for (var asset in assetController.assets) {
      if (selectedAssets.contains(asset.id)) {
        total += asset.totalValue * 0.025;
      }
    }

    // Calculate from selected incomes
    for (var income in incomeController.incomeEntries) {
      if (selectedIncomes.contains(income['id'])) {
        total += income['amount'] * 0.025;
      }
    }

    // Update the amount field
    amountController.text = total.toStringAsFixed(2);
  }
}
