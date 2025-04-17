import 'package:flutter/material.dart';

// ignore: must_be_immutable
class InputField extends StatelessWidget {
   InputField({
    this.inputType,
    super.key, required this.label,  this.prefix, this.postfix, this.controller, this.validate, this.maxLines, this.contentPadding,
  });
  final String label;
  final Icon? prefix;
  final Widget? postfix;
  final TextEditingController? controller;
  final String? Function(String?)? validate;
  final int? maxLines;
  final double? contentPadding;
  TextInputType? inputType;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: inputType,
      maxLines: maxLines,
      validator: validate,
      controller: controller,
        decoration:  InputDecoration(
          contentPadding: contentPadding==null?null:EdgeInsets.all(contentPadding??0),
          label: Text(label),
          prefixIcon: prefix,
          suffixIcon:postfix,
        )
    );
  }
}
