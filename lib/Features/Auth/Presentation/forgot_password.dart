

import 'package:finance/Features/Auth/Widgets/input_field.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';


import 'package:firebase_auth/firebase_auth.dart';


class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final TextEditingController _emailController = TextEditingController();

  // Method to send password reset email
  Future<void> _sendPasswordResetEmail() async {
    final String email = _emailController.text.trim();
    if (email.isEmpty) {
      Get.snackbar("Error", "Please enter your email address.");
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      Get.snackbar("Success", "Password reset email sent to $email.");
    } on FirebaseAuthException catch (e) {
      String errorMessage = "An error occurred. Please try again.";
      if (e.code == "user-not-found") {
        errorMessage = "No user found with this email.";
      } else if (e.code == "invalid-email") {
        errorMessage = "The email address is not valid.";
      }
      Get.snackbar("Error", errorMessage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(CupertinoIcons.clear)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Forgot Password',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 20),
            Text(
              "Don't worry if you forgot your password. Just enter your email to verify your account and set a new password!",
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 30),
            InputField(
              label: 'Email',
              prefix: const Icon(Iconsax.direct_right),
              controller: _emailController,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _sendPasswordResetEmail,
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


