import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'screens/onboarding/test_screen.dart';
import 'screens/onboarding/result_screen.dart';
import 'screens/onboarding/finance_setup_screen.dart';
import 'screens/onboarding/challenge_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/character_screen.dart';
import 'screens/danger_zone_screen.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/budget_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 임시 익명 로그인 (나중에 온보딩에서 처리 가능)
  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (_) => FirebaseAuth.instance.authStateChanges(),
          initialData: FirebaseAuth.instance.currentUser,
        ),
      ],
      child: const SoriApp(),
    ),
  );
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter _router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/onboarding/test',
  routes: [
    GoRoute(
      path: '/onboarding/test',
      builder: (context, state) => const TestScreen(),
    ),
    GoRoute(
      path: '/onboarding/result',
      builder: (context, state) => const ResultScreen(),
    ),
    GoRoute(
      path: '/onboarding/finance-setup',
      builder: (context, state) => const FinanceSetupScreen(),
    ),
    GoRoute(
      path: '/onboarding/challenge-setup',
      builder: (context, state) => const ChallengeSetupScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffold(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ledger',
              builder: (context, state) => const LedgerScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai',
              builder: (context, state) => const AiScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/character',
              builder: (context, state) => const CharacterScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/danger-zone',
              builder: (context, state) => const DangerZoneScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);

class SoriApp extends StatelessWidget {
  const SoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Sori App',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScaffold extends StatelessWidget {
  const MainScaffold({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: BottomNavigationBar(
          currentIndex: navigationShell.currentIndex,
          onTap: (index) => _onTap(context, index),
          type: BottomNavigationBarType.fixed,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: '홈'),
            BottomNavigationBarItem(icon: Icon(Icons.receipt_long_outlined), activeIcon: Icon(Icons.receipt_long), label: '가계부'),
            BottomNavigationBarItem(icon: Icon(Icons.psychology_outlined), activeIcon: Icon(Icons.psychology), label: 'AI'),
            BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), activeIcon: Icon(Icons.pets), label: '캐릭터'),
            BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), activeIcon: Icon(Icons.warning_rounded), label: '위험지역'),
          ],
        ),
      ),
    );
  }
}
