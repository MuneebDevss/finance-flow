
import 'package:finance/Features/bill/data/models/bill.dart';
import 'package:finance/Features/bill/presentation/controllers/bill_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class AddBillScreen extends StatefulWidget {
  final Bill? bill;
  
  const AddBillScreen({super.key, this.bill});
  
  @override
  _AddBillScreenState createState() => _AddBillScreenState();
}

class _AddBillScreenState extends State<AddBillScreen> {
  final BillController controller = Get.find<BillController>();
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  DateTime _dueDate = DateTime.now();
  String _recurrence = 'Monthly';
  String _paymentMethod = 'Credit Card';
  
  final List<String> _recurrenceOptions = ['One-time', 'Weekly', 'Monthly', 'Yearly'];
  final List<String> _paymentMethodOptions = ['Credit Card', 'Debit Card', 'Bank Transfer', 'Cash', 'Other'];
  
  @override
  void initState() {
    super.initState();
    
    // If editing, populate with existing bill data
    if (widget.bill != null) {
      _nameController = TextEditingController(text: widget.bill!.name);
      _amountController = TextEditingController(text: widget.bill!.amount.toString());
      _dueDate = widget.bill!.dueDate;
      _recurrence = widget.bill!.recurrence;
      _paymentMethod = widget.bill!.paymentMethod;
    } else {
      _nameController = TextEditingController();
      _amountController = TextEditingController();
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.bill != null ? 'Edit Bill' : 'Add New Bill'),
      ),
      body: Obx(() {
        return Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Bill Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.description),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a bill name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _amountController,
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        try {
                          double.parse(value);
                        } catch (e) {
                          return 'Please enter a valid amount';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(DateFormat('dd/MM/yyyy').format(_dueDate)),
                            Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Recurrence',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.repeat),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _recurrence,
                          isExpanded: true,
                          items: _recurrenceOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _recurrence = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Payment Method',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.payment),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _paymentMethod,
                          isExpanded: true,
                          items: _paymentMethodOptions.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _paymentMethod = newValue!;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: controller.isAdding.value ? null : _saveBill,
                        child: Text(
                          widget.bill != null ? 'Update Bill' : 'Add Bill',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isAdding.value)
              Container(
                color: Colors.black12,
                child: Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      }),
    );
  }
  
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }
  
  void _saveBill() {
    if (_formKey.currentState!.validate()) {
      final bill = Bill(
        id: widget.bill?.id,
        name: _nameController.text.trim(),
        amount: double.parse(_amountController.text),
        dueDate: _dueDate,
        recurrence: _recurrence,
        paymentMethod: _paymentMethod,
      );
      
      if (widget.bill != null) {
        // Update existing bill
        controller.deleteBill(widget.bill!.id!);
      }
      
      controller.addBill(bill);
    }
  }
}