import 'package:finance/Core/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController phoneController;
  final TextEditingController prefixController;

  PhoneInputField({super.key, 
    required this.phoneController,
    required this.prefixController,
  });

  final List<Map<String, String>> phonePrefixes = [
  // Middle Eastern Countries
  {'country': 'UAE', 'prefix': '+971'},
  {'country': 'KSA', 'prefix': '+966'},
  {'country': 'KWT', 'prefix': '+965'},
  {'country': 'QAT', 'prefix': '+974'},
  {'country': 'BHR', 'prefix': '+973'},
  {'country': 'OMN', 'prefix': '+968'},
  {'country': 'IRQ', 'prefix': '+964'},
  {'country': 'JOR', 'prefix': '+962'},
  {'country': 'LBN', 'prefix': '+961'},
  {'country': 'SYR', 'prefix': '+963'},
  
  // South Asian Countries
  {'country': 'IND', 'prefix': '+91'},
  {'country': 'PAK', 'prefix': '+92'},
  {'country': 'BGD', 'prefix': '+880'},
  {'country': 'LKA', 'prefix': '+94'},
  {'country': 'NPL', 'prefix': '+977'},
  {'country': 'AFG', 'prefix': '+93'},
  {'country': 'MDV', 'prefix': '+960'},
  {'country': 'BTN', 'prefix': '+975'},
  
  // More Countries from Europe and Asia
  {'country': 'UK', 'prefix': '+44'},
  {'country': 'DEU', 'prefix': '+49'},
  {'country': 'FRA', 'prefix': '+33'},
  {'country': 'ITA', 'prefix': '+39'},
  {'country': 'ESP', 'prefix': '+34'},
  {'country': 'TUR', 'prefix': '+90'},
  {'country': 'RUS', 'prefix': '+7'},
  {'country': 'GRC', 'prefix': '+30'},
  {'country': 'PRT', 'prefix': '+351'},
  {'country': 'BEL', 'prefix': '+32'},
  
  // Additional countries (Europe, Middle East & Asia)
  {'country': 'EGY', 'prefix': '+20'},
  {'country': 'ISR', 'prefix': '+972'},
  {'country': 'ARM', 'prefix': '+374'},
  {'country': 'GEO', 'prefix': '+995'},
  {'country': 'KAZ', 'prefix': '+7'},
  {'country': 'UZB', 'prefix': '+998'},
  {'country': 'TJK', 'prefix': '+992'},
  {'country': 'TKM', 'prefix': '+993'},
  {'country': 'AZE', 'prefix': '+994'},
  {'country': 'CYP', 'prefix': '+357'},
];




  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Dropdown for selecting phone number prefix
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Prefix',
              border: OutlineInputBorder(),
            ),
            value: prefixController.text.isEmpty
                ? null
                : prefixController.text,
            items: phonePrefixes.map((prefix) {
              return DropdownMenuItem<String>(
                value: prefix['prefix'],
                child: Text("${prefix['country']} ${prefix['prefix']}"),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                prefixController.text = value;
              }
            },
          ),
        ),
        const SizedBox(width: Sizes.spaceBtwInputFields),
        // Phone number input field
        Expanded(
          flex: 2,
          child: TextFormField(
            controller: phoneController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              prefixIcon: const Icon(Iconsax.call),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Phone number is required.';
  }
  // Validate phone number to have at least 10 digits
  final phoneRegExp = RegExp(r'^\d{10,}$');
  if (!phoneRegExp.hasMatch(value)) {
    return 'Please enter a valid phone number with at least 10 digits.';
  }
  return null;
},
          ),
        ),
      ],
    );
  }
}
