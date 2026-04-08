import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../controllers/nav_controller.dart';
import '../controllers/budget_controller.dart';
import 'screens/home/home_screen.dart';
import 'screens/expense/add_expense_screen.dart';
import 'screens/stats/stats_screen.dart';

/// 앱 최상단 Scaffold
/// GNav 하단 바 + IndexedStack으로 탭 전환
class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context) {
    final navCtrl = Get.find<NavController>();
    final budgetCtrl = Get.find<BudgetController>();

    return Obx(() {
      final theme = budgetCtrl.theme;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F3FF),
        body: SafeArea(
          child: IndexedStack(
            index: navCtrl.currentIndex.value,
            children: const [
              HomeScreen(),
              AddExpenseScreen(),
              StatsScreen(),
            ],
          ),
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(
                color: theme.primary.withOpacity(0.15),
                width: 1.5,
              ),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              child: GNav(
                selectedIndex: navCtrl.currentIndex.value,
                onTabChange: navCtrl.changeTo,
                color: const Color(0xFF9CA3AF),
                activeColor: theme.primary,
                tabBackgroundColor: theme.primary.withOpacity(0.12),
                gap: 8,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                tabs: const [
                  GButton(
                    icon: Icons.home_rounded,
                    text: '홈',
                  ),
                  GButton(
                    icon: Icons.add_circle_rounded,
                    text: '지출 추가',
                  ),
                  GButton(
                    icon: Icons.bar_chart_rounded,
                    text: '통계',
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
