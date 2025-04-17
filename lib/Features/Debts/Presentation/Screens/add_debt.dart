import 'package:finance/Features/Debts/Domain/debt_entity.dart';
import 'package:finance/Features/Debts/Domain/debt_repo.dart';
import 'package:finance/Features/Debts/Presentation/Screens/debt_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
class AddEditDebtScreen extends StatefulWidget {
  final Debt? debt;
  
  const AddEditDebtScreen({this.debt});
  
  @override
  _AddEditDebtScreenState createState() => _AddEditDebtScreenState();
}

class _AddEditDebtScreenState extends State<AddEditDebtScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime? _selectedDueDate;
  final DebtRepository _repository = DebtRepository();

  @override
  void initState() {
    super.initState();
    if (widget.debt != null) {
      _nameController.text = widget.debt!.name;
      _amountController.text = widget.debt!.totalAmount.toString();
      _selectedDueDate = widget.debt!.dueDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.debt == null ? 'Add New Debt' : 'Edit Debt'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Debt Name',
                            prefixIcon: Icon(Icons.description),
                            border: OutlineInputBorder(),
                            filled: true,
                            
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter a name';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        TextFormField(
                          controller: _amountController,
                          decoration: InputDecoration(
                            labelText: 'Total Amount',
                            prefixIcon: Icon(Icons.attach_money),
                            border: OutlineInputBorder(),
                            filled: true,
                            
                          ),
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Please enter an amount';
                            }
                            if (double.tryParse(value!) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16),
                        InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _selectedDueDate ?? DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 3650)),
                            );
                            if (date != null) {
                              setState(() => _selectedDueDate = date);
                            }
                          },
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Due Date (Optional)',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                              filled: true,
                              
                            ),
                            child: Text(
                              _selectedDueDate == null
                                  ? 'Select Due Date'
                                  : DateFormat('MMM dd, yyyy').format(_selectedDueDate!),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _saveDebt,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    widget.debt == null ? 'Add Debt' : 'Update Debt',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveDebt() async {
    if (!_formKey.currentState!.validate()) return;

    final debt = Debt(
      id: widget.debt?.id ?? '',
      name: _nameController.text,
      totalAmount: double.parse(_amountController.text),
      remainingBalance: double.parse(_amountController.text),
      dueDate: _selectedDueDate,
      userId: FirebaseAuth.instance.currentUser!.uid,
      createdAt: widget.debt?.createdAt ?? DateTime.now(),
    );

    try {
      if (widget.debt == null) {
        await _repository.addDebt(debt);
      } else {
        await _repository.updateDebt(debt);
      }
    Get.offAll(()=>DebtListScreen());
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving debt: $e')),
      );
    }
  }
}