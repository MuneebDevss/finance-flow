import 'package:finance/Core/DeviceUtils/device_utils.dart';
import 'package:flutter/material.dart';

class PasswordFieldWithRequirements extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?) validate;

  const PasswordFieldWithRequirements({
    super.key,
    required this.controller,
    required this.validate,
  });

  @override
  State<PasswordFieldWithRequirements> createState() =>
      _PasswordFieldWithRequirementsState();
}

class _PasswordFieldWithRequirementsState
    extends State<PasswordFieldWithRequirements> {
  final List<_PasswordRequirement> _requirements = [
    _PasswordRequirement(
        label: 'At least 8 characters', validator: (value) => value.length >= 8),
    _PasswordRequirement(
        label: 'At least one uppercase letter',
        validator: (value) => RegExp(r'[A-Z]').hasMatch(value)),
    _PasswordRequirement(
        label: 'At least one lowercase letter',
        validator: (value) => RegExp(r'[a-z]').hasMatch(value)),
    _PasswordRequirement(
        label: 'At least one number',
        validator: (value) => RegExp(r'\d').hasMatch(value)),
    _PasswordRequirement(
        label: 'At least one special character (e.g., @, #)',
        validator: (value) => RegExp(r'[@#\$%^&*!]').hasMatch(value)),
  ];
  bool _obscureText = true;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: (){
                _obscureText=!_obscureText;
                setState(() {
                  
                });
              },
            ),
          ),
          validator: widget.validate,
          onChanged: (value) {
            setState(() {}); // Rebuild to update the checkboxes
          },
        ),
        const SizedBox(height: 16),
        ..._requirements.map((requirement) {
          final isValid = requirement.validator(widget.controller.text);
          return Row(
            children: [
              Checkbox(
                value: isValid,
                onChanged: (_) {},
                checkColor: Colors.white,
                activeColor: Colors.green,
              ),
              SizedBox(
                width: TDeviceUtils.getScreenWidth(context)/1.5,
                child: Text(requirement.label)),
            ],
          );
        }),
      ],
    );
  }
}

class _PasswordRequirement {
  final String label;
  final bool Function(String) validator;

  _PasswordRequirement({required this.label, required this.validator});
}
