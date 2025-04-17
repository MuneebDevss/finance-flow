
import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Features/Auth/Presentation/Controllers/sign_up_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DateOfBirthWidget extends StatefulWidget {
  final SignUpController myController;

  const DateOfBirthWidget({super.key, required this.myController});
  @override
  State<DateOfBirthWidget> createState() => _DateOfBirthWidgetState();
}

class _DateOfBirthWidgetState extends State<DateOfBirthWidget> {
  late DateTime dateOfBirth ;
@override
  void initState() {
    // TODO: implement initState
    dateOfBirth=widget.myController.dateOfBirth;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: HelpingFunctions.isDarkMode(context) ? Colors.white : Colors.black,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "Date of Birth: ${_formatDate(dateOfBirth)}",
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          IconButton(
            onPressed: () => _showDatePicker(context),
            icon: const Icon(Icons.calendar_today, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  void _showDatePicker(BuildContext context) async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: dateOfBirth,
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
      helpText: "Select Date of Birth", // Optional help text
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue, // Header background color
              onPrimary: Colors.white, // Header text color
              onSurface: Colors.black, // Body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && selectedDate != dateOfBirth) {
      setState(() {
        dateOfBirth = selectedDate;
        widget.myController.dateOfBirth = selectedDate; // Update controller
      });
    }
  }

  String _formatDate(DateTime date) {
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }
}
