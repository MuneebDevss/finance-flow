
import 'package:finance/Core/DeviceUtils/connectivity.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Auth/Presentation/email_verification.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SignUpController extends GetxController {
  static final signUpController = Get.find<SignUpController>();
  final NetworkManager manager = Get.put(NetworkManager());
  bool checked=false;
  final email = TextEditingController();
    final phone = TextEditingController();
    final TextEditingController prefixController = TextEditingController(text: "+92");

  final username = TextEditingController();
  final password = TextEditingController();
  DateTime dateOfBirth =DateTime(1996, 10, 22);
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void onClose() {
    email.dispose();
       phone.dispose();
    username.dispose();
    password.dispose();
    super.onClose();
  }


  bool validateDateOfBirth() {
  final currentDate = DateTime.now();
  int  age = currentDate.year - dateOfBirth.year;

  // Adjust age if the birthday hasn't occurred yet this year
  if (currentDate.month < dateOfBirth.month || 
      (currentDate.month == dateOfBirth.month && currentDate.day < dateOfBirth.day)) {
    age--;
  }

  if (age >= 18) {
    // Valid age, show success snackbar
    return true;
  } else {
    // Invalid age, show error snackbar
    Get.snackbar(
      "Age Validation Failed",
      "You must be at least 18 years old.",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: Duration(seconds: 2),
    );
    return false;
  }
}



  String? secondNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Second name is required.';
    }
    final nameRegExp = RegExp(r'\d');
    if (nameRegExp.hasMatch(value)) {
      return 'You cannot have digit in your name';
    }
    return null;
  }
  final RxBool isLoading = false.obs;
  

  Future<void> validateAll() async {
    if (await manager.isConnected() == false) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(content: Text('No internet connection')),
      );
      return;
    }

    // Age validation
    final today = DateTime.now();
    final birthDate = dateOfBirth;
    final age = today.year - birthDate.year - 
        (today.month < birthDate.month || 
        (today.month == birthDate.month && today.day < birthDate.day) ? 1 : 0);
    
    if (age < 18) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          elevation: 3,
          showCloseIcon: true,
          closeIconColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'You must be at least 18 years old to register',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow,
        ),
      );
      return;
    }

    if (!checked) {
      ScaffoldMessenger.of(Get.context!).showSnackBar(
        const SnackBar(
          elevation: 3,
          showCloseIcon: true,
          closeIconColor: Colors.black,
          behavior: SnackBarBehavior.floating,
          content: Text(
            'Agree and Read the terms and conditions',
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.yellow,
        ),
      );
      return;
    }

    final formState = formKey.currentState;
    if (formState != null && formState.validate()) {
      isLoading.value = true; // Show loading
      try {
        // Simulate registration process
        await UsersRepository().registerUser(
          email: email.text.trim(), 
          password: password.text, 
          name: username.text, 
          dateOfBirth: dateOfBirth, 
          phoneNumber: prefixController.text + phone.text
        );
        Get.to(() => EmailVerifcation(email: email.text.trim())); // Navigate on success
      } catch (e) {
        ScaffoldMessenger.of(Get.context!).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        isLoading.value = false; // Hide loading
      }
    }
}

  String? validateEmail(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Email is required.';
  }
  final emailRegExp = RegExp(r'^[\w.]+@(\w+\.)+\w{2,4}$');
  if (!emailRegExp.hasMatch(value)) {
    return 'Invalid email address.';
  }
  if (!value.contains('@') || !value.endsWith('.com')) {
    return 'Email must contain "@" and end with ".com".';
  }
  return null;
}

String? validatePassword(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Password is required.';
  }
  if (value.length < 8) {
    return 'Password must be at least 8 characters long.';
  }
  if (!RegExp(r'[A-Z]').hasMatch(value)) {
    return 'Password must contain at least one uppercase letter.';
  }
  if (!RegExp(r'[a-z]').hasMatch(value)) {
    return 'Password must contain at least one lowercase letter.';
  }
  if (!RegExp(r'\d').hasMatch(value)) {
    return 'Password must contain at least one number.';
  }
  if (!RegExp(r'[@#\$%^&*!]').hasMatch(value)) {
    return 'Password must contain at least one special character (e.g., @, #).';
  }
  return null;
}

String? validatePhoneNumber(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Phone number is required.';
  }
  // Validate phone number to have at least 10 digits
  final phoneRegExp = RegExp(r'^\d{10,}$');
  if (!phoneRegExp.hasMatch(value)) {
    return 'Please enter a valid phone number with at least 10 digits.';
  }
  return null;
}

String? validateUserName(String? value) {
  if (value == null || value.trim().isEmpty) {
    return 'Name is required.';
  }
  // Ensure name has at least one alphabet and no digits
  if (RegExp(r'\d').hasMatch(value)) {
    return 'Name must not contain digits.';
  }
  if (!RegExp(r'[A-Za-z]').hasMatch(value)) {
    return 'Name must contain at least one alphabet.';
  }
  return null;
}




}
