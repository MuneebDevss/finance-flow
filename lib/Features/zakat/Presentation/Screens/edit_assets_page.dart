import 'package:finance/Features/zakat/Presentation/controller/asset_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
class EditAssetPage extends StatelessWidget {
  final String assetId;
  final AssetController controller = Get.find<AssetController>();
  
  EditAssetPage({required this.assetId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Asset'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Asset Name
              TextField(
                controller: controller.assetNameController,
                decoration: InputDecoration(
                  labelText: 'Asset Name*',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              
              // Asset Type
              Text('Asset Type*', style: TextStyle(fontSize: 16)),
              SizedBox(height: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: controller.selectedAssetType.value.isEmpty ? null : controller.selectedAssetType.value,
                    hint: Text('Select Asset Type'),
                    items: controller.assetTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        controller.selectedAssetType.value = newValue;
                      }
                    },
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Value
              TextField(
                controller: controller.valueController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Value per Unit*',
                  border: OutlineInputBorder(),
                  prefixText: '\$ ',
                ),
              ),
              SizedBox(height: 16),
              
              // Quantity
              TextField(
                controller: controller.quantityController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Default: 1',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              
              // Acquisition Date
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: controller.selectedDate.value ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) {
                    controller.selectedDate.value = picked;
                  }
                },
                child: AbsorbPointer(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          controller.selectedDate.value == null
                              ? 'Select Acquisition Date*'
                              : 'Date: ${DateFormat('MMM dd, yyyy').format(controller.selectedDate.value!)}',
                          style: TextStyle(
                            fontSize: 16,
                            color: controller.selectedDate.value == null
                                ? Colors.grey.shade600
                                : Colors.black,
                          ),
                        ),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              
              // Notes
              TextField(
                controller: controller.notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Notes (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 24),
              
              // Update Button
              Center(
                child: ElevatedButton(
                  onPressed: () => controller.updateAsset(assetId),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 48, vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                  child: Text('Update Asset'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}