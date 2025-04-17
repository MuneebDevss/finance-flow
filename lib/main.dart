import 'package:finance/Core/Theme/theme.dart';
import 'package:finance/Features/Auth/Presentation/email_verification.dart';
import 'package:finance/Features/Auth/Presentation/login_page.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_history.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_page_.dart';
import 'package:finance/Features/Settings/Presenation/Controllers/theme_controller.dart';
import 'package:finance/Features/bill/presentation/Screens/add_bill_page.dart';
import 'package:finance/Features/bill/presentation/Screens/bill_dashboard.dart';
import 'package:finance/Features/bill/presentation/Screens/bill_history.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

final getPages = [
  GetPage(name: '/bills', page: () => BillDashboardScreen()),
  GetPage(name: '/bills/add', page: () => AddBillScreen()),
  GetPage(name: '/bills/history', page: () => BillHistoryScreen()),
  GetPage(
    name: '/budget',
    page: () => MonthlyBudgetPage(),
    binding: BudgetBinding(),
  ),
  // other routes...
];
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  Get.put(ThemeController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      return GetMaterialApp(
        getPages: getPages,
        theme: themeController.isDarkMode
            ? TAppTheme.darkTheme
            : TAppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: AppStart(),
      );
    });
  }
}

class AppStart extends StatelessWidget {
  const AppStart({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _checkUserSession(),
      builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while waiting for Firebase initialization
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasData) {
          // Navigate to the respective page
          return snapshot.data!;
        } else {
          // Fallback in case of an unexpected scenario
          return const Scaffold(
            body: Center(child: Text('Unexpected Error Occurred')),
          );
        }
      },
    );
  }

  Future<Widget> _checkUserSession() async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    if (currentUser == null) {
      // No user session found, navigate to LoginPage
      return LoginPage();
    } else if (!currentUser.emailVerified) {
      // User is signed in but email is not verified
      return EmailVerifcation(
        email: currentUser.email!,
      );
    } else {
      // User is signed in and email is verified
      return IncomeListPage();
    }
  }
}
