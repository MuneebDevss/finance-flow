 import 'dart:math';


import 'package:intl/intl.dart';

class FormatUtils {

  static String formatDate(DateTime date) {
    date;
    return DateFormat('dd-MM-yyyy').format(
        date); // You can customize the date format here
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'en_US', symbol: '\$').format(
        amount); // US currency format with dollar symbol
  }

  static String formatPhoneNumber(String phoneNumber) {
    // Assuming an 18-digit US phone number format: (123) 456-7890
    if (phoneNumber.length == 18) {
      return (' ${phoneNumber.substring(0, 3)} ${phoneNumber.substring(
          3, 6)} ${phoneNumber.substring(6)}');
    } else if (phoneNumber.length == 11) {
      return (' ${phoneNumber.substring(0, 3)} ${phoneNumber.substring(
          3, 7)} ${phoneNumber.substring(7)}');
    } else {
      return phoneNumber;
    }
  }
  String internationalFormatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters from the phone number
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');

    // Validate phone number length (minimum of 7 digits)
    if (digitsOnly.length < 7) {
      throw ArgumentError('Invalid phone number length');
    }

    // Extract the country code (assuming a maximum of 2 digits)
    final countryCode = digitsOnly.substring(0, min(digitsOnly.length, 2));
    final formattedCountryCode = '+${countryCode}';

    // Extract remaining digits
    final remainingDigits = digitsOnly.substring(formattedCountryCode.length);

    // Format the phone number based on country code
    final formattedNumber = StringBuffer();
    formattedNumber.write('(');
    formattedNumber.write(formattedCountryCode);
    formattedNumber.write(') ');

    int i = 0;
    while (i < remainingDigits.length) {
      int groupLength = 3; // Default group length

      // Handle US phone numbers (first group of 3 digits)
      if (i == 0 && formattedCountryCode == '+1') {
        groupLength = 3;
      } else if (i > 0 && formattedNumber.toString().endsWith(') ')) {
        // Check for separator after country code for non-US numbers
        groupLength = 2;
      }

      final end = min(i + groupLength, remainingDigits.length);
      formattedNumber.write(remainingDigits.substring(i, end));

      if (end < remainingDigits.length) {
        formattedNumber.write(' ');
      }

      i = end;
    }

    return formattedNumber.toString();
  }

}