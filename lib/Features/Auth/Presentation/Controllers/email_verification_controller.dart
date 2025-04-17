import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_page_.dart';
import 'package:get/get.dart';

class EmailVerificationController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final RxBool isLoading = false.obs;
  final RxBool isVerified = false.obs;
  Future<void> checkEmailVerified() async {
    try {
      User? user = _auth.currentUser;
      await user?.reload(); // Reload user to get the latest state
      isVerified.value = user!.emailVerified;

      if (isVerified.value) {
        Get.snackbar(
          "Success",
          "Your email is verified.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Future.delayed(Duration(seconds: 2),()=>Get.offAll(()=>IncomeListPage()));
      } else {
        Get.snackbar(
          "Pending",
          "Your email is not verified yet. Please verify it.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to check email verification status: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      isLoading.value = true;

      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        Get.snackbar(
          "Email Sent",
          "Verification email has been sent. Please check your inbox.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          "Already Verified",
          "Your email is already verified.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to send verification email: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onInit() {
    sendEmailVerification();
    
    super.onInit();
  }
}

