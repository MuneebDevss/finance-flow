

import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Features/Auth/Domain/Repository/auth_repository.dart';
import 'package:finance/Features/Auth/Presentation/Controllers/login_controller.dart';
import 'package:finance/Features/Auth/Presentation/signup.dart';
import 'package:finance/Features/Auth/Widgets/input_field.dart';
import 'package:finance/Features/Auth/Widgets/password_field.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'forgot_password.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool isChecked = false;
  final controller=Get.put(LoginController(usersRepository: UsersRepository()),tag: UniqueKey().toString());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(Sizes.defaultSpace),
        child: SingleChildScrollView(
          //header
          child: Form(
            key: controller.formKey,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    height: Sizes.appBarHeight*2.5,
                  ),
                  SizedBox(
                    width: Sizes.iconXlg,
                    child: Image.asset('assets/images/Login.png')),
                  const SizedBox(
                    height: Sizes.spaceBtwItems,
                  ),
                  Text(
                    "Finance Management",
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.start,
                  ),
                  const SizedBox(
                    height: Sizes.sm,
                  ),
                  Text(
                'Manage Your Finances with Ease and Track Expenses Effortlessly',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.start,
              )
              ,
                  const SizedBox(
                    height:
                        Sizes.spaceBtwInputFields + Sizes.spaceBtwInputFields,
                  ),
                   SizedBox(
                    width: double.infinity,
                    child: InputField(
                      controller: controller.email,
                      validate: controller.validateEmail,
                      label: 'Email', prefix: const Icon(Icons.email_outlined),),
                  ),
                  const SizedBox(
                    height: Sizes.spaceBtwInputFields,
                  ),
                   SizedBox(
              
                    width: double.infinity,
                    child: PasswordField(
                      controller: controller.password,
                      validate: controller.validatePassword,
                    ),
                  ),
                  Row(
                    children: [
                      const SizedBox(
                        width: Sizes.xs,
                      ),
                      Checkbox(
                          value: isChecked,
                          onChanged: (val) {
                            if (val != null) {
                              isChecked = val;
                            }
                            setState(() {});
                          }),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Remember Me',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
              
                            TextButton(onPressed: (){
                              Get.to(()=>const ForgotPassword());
                            }, child: Text('Forgot Password?',
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge!
                                  .copyWith(color: Colors.blue),))
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: Sizes.spaceBtwSections,
                  ),
                  Obx(() {
                            if (controller.isLoading.value) {
              return const CircularProgressIndicator(); // Loading indicator
                            }
                            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if(controller.formKey.currentState!.validate()) {
                    controller.login();
                  }
                },
                child: const Text('Login'),
              ),
                            );
                          }),
                  const SizedBox(
                    height: Sizes.spaceBtwItems,
                  ),
                  SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
              
                          onPressed: () =>Get.to(()=>const SignUp()),
                          child: const Text('Create Account'))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

