
import 'package:finance/Features/Settings/Presenation/Controllers/theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingsPage extends StatelessWidget {
  final ThemeController themeController = Get.put(ThemeController());

   SettingsPage({super.key});
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Dark Mode',
              style: TextStyle(fontSize: 18),
            ),
            Obx(
              () => Switch(
                value: themeController.isDarkMode,
                onChanged: (value) => themeController.toggleTheme(value),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
