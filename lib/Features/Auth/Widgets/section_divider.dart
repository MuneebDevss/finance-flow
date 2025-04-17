import 'package:flutter/material.dart';
import '../../../Core/HelpingFunctions/helper_functions.dart';

class SectionDivider extends StatelessWidget {
  const SectionDivider({
    super.key, required this.dividerText,
  });
  final String dividerText;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Divider(
            color: HelpingFunctions.isDarkMode(context)
                ? Colors.white
                : Colors.grey,
            thickness: 0.5,
            indent: 60,
            endIndent: 5,
          ),
        ),
        Text(
          dividerText,
          style: Theme.of(context).textTheme.labelLarge,
        ),
        Flexible(
          child: Divider(
            color: HelpingFunctions.isDarkMode(context)
                ? Colors.white
                : Colors.grey,
            thickness: 0.5,
            indent: 5,
            endIndent: 60,
          ),
        ),
      ],
    );
  }
}
