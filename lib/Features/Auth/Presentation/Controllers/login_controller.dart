import 'package:finance/Core/DeviceUtils/connectivity.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_page_.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

class LoginController extends GetxController
{
  final email = TextEditingController();
  final password = TextEditingController();
  final NetworkManager manager = Get.put(NetworkManager());
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  void onClose() {
    super.onClose();
  }
  final UsersRepository usersRepository;
  final RxBool isLoading = false.obs;

  LoginController({required this.usersRepository});

  Future<void> login( ) async {
    try {
      isLoading.value = true; // Start loading
      UserEntity? user = await usersRepository.loginUser(email.text.trim(), password.text.trim());
      final bool isVerified=await usersRepository.checkEmailVerified();
      if (user != null) {
        if(isVerified) {
          Get.to(() => IncomeListPage());
        } else{
          Get.snackbar("Error", "Email not verified yet", snackPosition: SnackPosition.BOTTOM);
        } // Navigate to HomePage
      } else {
        Get.snackbar("Error", "User not found",
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar("Error", "Invalid Credentials", snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false; // Stop loading
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
    return null;
  }
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required.';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }
    if (!RegExp('[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter.';
    }
    return null;
  }

}