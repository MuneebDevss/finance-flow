
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Auth/Presentation/Controllers/email_verification_controller.dart';
import 'package:finance/Features/Auth/Presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EmailVerifcation extends StatelessWidget {
   EmailVerifcation({super.key, required this.email});
  final String email;
  final controller=Get.put(EmailVerificationController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
  title: Text('Email Verfication'),
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () {
      // Navigate back to the LoginPage
      Get.offAll(()=>LoginPage());
    },
  ),
)
,
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: 
           Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.verified_user_outlined),
              const SizedBox(height: Sizes.spaceBtwItems,),
              Text('Verify Your Email address!',style: Theme.of(context).textTheme.headlineSmall,textAlign: TextAlign.center,),
              const SizedBox(height: Sizes.spaceBtwItems,),
              Text(email,style: Theme.of(context).textTheme.bodyLarge,textAlign: TextAlign.center,),
              const SizedBox(height: Sizes.spaceBtwItems,),
              Text("Congratulations! Your Account is Ready. Verify Your Email to Start Managing Your Expenses, Planning Your Budget, and Achieving Your Savings Goals with Personalized Insights and Tools.",style: Theme.of(context).textTheme.bodySmall,textAlign: TextAlign.center,),
              const SizedBox(height: Sizes.spaceBtwSections,),
              Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Obx(() {
              return controller.isVerified.value
                  ? Center(
                    child: const Text(
                        "Your email is verified!",
                        style: TextStyle(fontSize: 18, color: Colors.green),
                      ),
                  )
                  : Center(
                    child: const Text(
                        "Your email is not verified yet.",
                        style: TextStyle(fontSize: 18, color: Colors.red),
                      ),
                  );
            }),
            const SizedBox(height: 20),
            Obx(() {
              return controller.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: controller.sendEmailVerification,
                      child: const Text("Send Verification Email"),
                    );
            }),
            const SizedBox(height: 20),
            TextButton(
              onPressed: controller.checkEmailVerified,
              child: const Text("Check Email Verification"),
            ),
          ],
        )
            ],
          ),
        ),
      
    );
  }
}
