import 'package:finance/Core/HelpingFunctions/helper_functions.dart';
import 'package:finance/Core/HelpingFunctions/widgets/app_drawer.dart';
import 'package:finance/Core/HelpingFunctions/widgets/profile.dart';
import 'package:finance/Features/Auth/Presentation/login_page.dart';
import 'package:finance/Features/Settings/Presenation/Screens/settings_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: bottomNavigationWidget(5),
      appBar: AppBar(
        leading: Icon(Icons.person),
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF000B58),
                Colors.blue[500]!,
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person_outline, color: Colors.blue[700]),
              ),
              title: const Text(
                'My Profile',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () => Get.to(() => const MyProfile()),
            ),
            const SizedBox(height: 16),
            // ListTile(
            //   leading: Container(
            //     padding: const EdgeInsets.all(8),
            //     decoration: BoxDecoration(
            //       color: Colors.green[50],
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Icon(Icons.settings_outlined, color: Colors.green[700]),
            //   ),
            //   title: const Text(
            //     'Settings',
            //     style: TextStyle(fontWeight: FontWeight.w500),
            //   ),
            //   onTap: () => Get.to(() => SettingsPage()),
            // ),
            const SizedBox(height: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.logout_outlined, color: Colors.red),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
              onTap: () async {
                final confirm = await showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    title: const Text(
                      'Log Out',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    content: const Text('Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          'CANCEL',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text(
                          'LOG OUT',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  try {
                    await FirebaseAuth.instance.signOut();
                    Get.offAll(() => const LoginPage());
                  } catch (e) {
                    if (Get.context != null) {
                      HelpingFunctions.showSnackBar(Get.context!, e.toString());
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Update the navigation switch case
