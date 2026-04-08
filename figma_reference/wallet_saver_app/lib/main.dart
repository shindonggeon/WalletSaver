import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/core/theme/app_theme.dart';
import 'app/controllers/budget_controller.dart';
import 'app/controllers/expense_controller.dart';
import 'app/controllers/nav_controller.dart';
import 'app/views/main_scaffold.dart';

void main() { 
  WidgetsFlutterBinding.ensureInitialized();
  
  // Dependency Injection (상태 관리 컨트롤러 등록)
  Get.put(BudgetController());
  Get.put(ExpenseController());
  Get.put(NavController());

  runApp(const WalletSaverApp());
}

class WalletSaverApp extends StatelessWidget {
  const WalletSaverApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "지갑비서 '소리'",
      debugShowCheckedModeBanner: false, // 디버그 배너 숨김
      theme: AppTheme.light,      // Phase 1에서 생성한 전역 테마
      home: const MainScaffold(),      // 진입점 메인 뼈대 (GNav 포함)
      defaultTransition: Transition.fadeIn,
    );
  }
}
