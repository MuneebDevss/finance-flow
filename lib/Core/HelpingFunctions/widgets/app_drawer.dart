import 'package:finance/Core/HelpingFunctions/widgets/profile_nav.dart';
import 'package:finance/Features/BudgetPlanning/Presentation/Screens/budget_planner_page.dart';
import 'package:finance/Features/Debts/Presentation/Screens/debt_list.dart';
import 'package:finance/Features/Expense/Presentation/Screens/expense_list.dart';
import 'package:finance/Features/Income/Presentation/Screens/income_page_.dart';
import 'package:finance/Features/SavingGoals/Presentation/Screens/saving_goals_page.dart';
import 'package:finance/Features/bill/presentation/Screens/bill_dashboard.dart';
import 'package:finance/Features/stocks/Presentation/Screens/asset_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// BottomNavigationBar bottomNavigationWidget(int selected) {
//   return BottomNavigationBar(
//     type: BottomNavigationBarType.shifting,
//     currentIndex: selected,
//     elevation: 8.0,
//     backgroundColor: Colors.white,
//     selectedItemColor: Colors.blue[700],
//     unselectedItemColor: Colors.grey[600],
//     selectedLabelStyle: const TextStyle(
//       fontWeight: FontWeight.w600,
//       fontSize: 12,
//     ),
//     unselectedLabelStyle: const TextStyle(
//       fontWeight: FontWeight.normal,
//       fontSize: 11,
//     ),
//     onTap: (value) {
//       int temp = selected;
//       selected = value;
//       navigate(value, temp);
//     },
//     items: const [
//       BottomNavigationBarItem(
//         icon: Icon(Icons.dashboard_outlined),
//         activeIcon: Icon(Icons.dashboard),
//         label: 'Income',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.account_balance_wallet_outlined),
//         activeIcon: Icon(Icons.account_balance_wallet),
//         label: 'Expenses',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.trending_up_outlined),
//         activeIcon: Icon(Icons.trending_up),
//         label: 'Budget',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.trending_down_outlined),
//         activeIcon: Icon(Icons.trending_down),
//         label: 'Debt',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.savings_outlined),
//         activeIcon: Icon(Icons.savings),
//         label: 'Savings',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.receipt_long_outlined),
//         activeIcon: Icon(Icons.receipt),
//         label: 'Bills',
//       ),
//       BottomNavigationBarItem(
//         icon: Icon(Icons.person_outline),
//         activeIcon: Icon(Icons.person),
//         label: 'Profile',
//       ),
//     ],
//   );
// }
Widget bottomNavigationWidget(int selected) {
  // List of navigation items
  final List<Map<String, dynamic>> navItems = const [
    {
      'icon': Icons.dashboard_outlined,
      'activeIcon': Icons.dashboard,
      'label': 'Income',
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
      'activeIcon': Icons.account_balance_wallet,
      'label': 'Expenses',
    },
    {
      'icon': Icons.trending_up_outlined,
      'activeIcon': Icons.trending_up,
      'label': 'Budget',
    },
    {
      'icon': Icons.trending_down_outlined,
      'activeIcon': Icons.trending_down,
      'label': 'Debt',
    },
    {
      'icon': Icons.savings_outlined,
      'activeIcon': Icons.savings,
      'label': 'Savings',
    },
    {
      'icon': Icons.receipt_long_outlined,
      'activeIcon': Icons.receipt,
      'label': 'Bills',
    },
    {
      'icon': Icons.currency_bitcoin_sharp,
      'activeIcon': Icons.currency_bitcoin_outlined,
      'label': 'Stocks',
    },
    
    {
      'icon': Icons.person_outline,
      'activeIcon': Icons.person,
      'label': 'Profile',
    },
  ];

  return Container(
    height: 65,
    decoration: BoxDecoration(
      color: Color(0xFF000B58),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.3),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, -1),
        ),
      ],
    ),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: List.generate(
          navItems.length,
          (index) => InkWell(
            onTap: () {
              int temp = selected;
              navigate(index, temp);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    selected == index
                        ? navItems[index]['activeIcon']
                        : navItems[index]['icon'],
                    color:
                        selected == index ? Colors.blue[700] : Colors.grey[600],
                    size: 24,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    navItems[index]['label'],
                    style: TextStyle(
                      color: selected == index
                          ? Colors.blue[700]
                          : Colors.grey[600],
                      fontSize: selected == index ? 12 : 11,
                      fontWeight: selected == index
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void navigate(int value, int selected) {
  if (selected == value) {
    return;
  }

  Transition getTransition(int selected, int value) {
    return selected > value
        ? Transition.leftToRightWithFade
        : Transition.rightToLeftWithFade;
  }

  const duration = Duration(milliseconds: 300);

  switch (value) {
    case 0:
      Get.offAll(
        () => const IncomeListPage(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;

    case 1:
      Get.offAll(
        () => const ExpenseListScreen(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;

    case 2:
      Get.offAll(
        () => const BudgetDashboard(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;

    case 3:
      Get.offAll(
        () => DebtListScreen(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;

    case 4:
      Get.offAll(
        () => SavingsPage(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;

    case 5:
      Get.offAll(
        () => BillDashboardScreen(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;
    case 6:
      Get.offAll(
        () => AssetListScreen(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;
    case 7:
      Get.offAll(
        () => const ProfilePage(),
        transition: getTransition(selected, value),
        duration: duration,
      );
      break;
  }
}
