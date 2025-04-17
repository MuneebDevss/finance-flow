import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key, this.controller, this.validate,
  });
  final TextEditingController? controller;
  final String? Function(String?)? validate;
  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  bool eyeCheck=true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: eyeCheck,
      validator: widget.validate,
      controller: widget.controller,
      decoration: InputDecoration(
          hintText: 'Password',
          label: const Text('Password'),
          prefixIcon: const Icon(Icons.password),
          suffixIcon:eyeCheck? GestureDetector(
              onTap: () {
                eyeCheck=false;
                setState(() {

                });
              },
              child: const Icon(Iconsax.eye_slash4)):GestureDetector(
              onTap: () {
                eyeCheck=true;
                setState(() {

                });
              },
              child: const Icon(Iconsax.eye4))
      ),
    );
  }
}