
import 'package:finance/Core/constants/sizes.dart';
import 'package:finance/Core/constants/text_constants.dart';
import 'package:finance/Features/Auth/Presentation/Controllers/sign_up_controller.dart';
import 'package:finance/Features/Auth/Widgets/date_picker_widget.dart';
import 'package:finance/Features/Auth/Widgets/input_field.dart';
import 'package:finance/Features/Auth/Widgets/password_with_req_specified.dart';
import 'package:finance/Features/Auth/Widgets/phone_field.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final SignUpController myController =
      SignUpController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Sizes.defaultSpace),
        child: SingleChildScrollView(
          child: Form(
            key: myController.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                Text(
                  ConstantTexts.signUpTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                SizedBox(
                  child: InputField(
                      controller: myController.username,
                      validate: myController.validateUserName,
                      label: 'Username',
                      prefix: const Icon(
                        Iconsax.user_edit,
                      )),
                ),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                SizedBox(
                  child: InputField(
                    label: 'Email',
                    prefix: const Icon(Iconsax.direct),
                    validate: myController.validateEmail,
                    controller: myController.email,
                  ),
                ),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                PhoneInputField(phoneController: myController.phone, prefixController: myController.prefixController,),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                SizedBox(
  child: DateOfBirthWidget(myController: myController,),
)
,

                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),

                SizedBox(
                  child: PasswordFieldWithRequirements(controller: myController.password, validate: myController.validatePassword,
                ),),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Checkbox(
                        value: myController.checked,
                        onChanged: (val) {
                          if (val != null) {
                            myController.checked = val;
                          }
                          setState(() {});
                        }),
                    RichText(
                        text: TextSpan(
                            text: 'I agree to ',
                            style: Theme.of(context).textTheme.labelLarge,
                            children: [
                          TextSpan(
                            text: 'Privacy Policy',
                            style:
                                Theme.of(context).textTheme.labelLarge!.apply(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                          ),
                          const TextSpan(text: ' and '),
                          TextSpan(
                            text: 'Terms of Use',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge!
                                .apply(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.blue),
                          )
                        ])),
                  ],
                ),
                const SizedBox(
                  height: Sizes.spaceBtwItems,
                ),
                 Obx(() {
                if (myController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SizedBox(width: double.infinity,
                  child: ElevatedButton(
                    onPressed: myController.validateAll,
                    child: const Text('Create Account'),
                  ),
                );
              }),
                const SizedBox(
                  height: Sizes.spaceBtwSections,
                ),
                //const SectionDivider(dividerText: 'or Sign Up with'),
                const SizedBox(
                  height: Sizes.spaceBtwSections,
                ),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                   // OtherAuthMethods(),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
