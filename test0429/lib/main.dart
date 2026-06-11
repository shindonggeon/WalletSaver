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
import 'screens/onboarding/nickname_setup_screen.dart';
import 'screens/manage_finance_screen.dart';
import 'screens/home_screen.dart';
import 'screens/ledger_screen.dart';
import 'screens/character_screen.dart';
import 'screens/danger_zone_screen.dart';
import 'services/notification_service.dart';
import 'services/demo_service.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await NotificationService.initialize();

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
  initialLocation: '/onboarding/nickname',
  routes: [
    GoRoute(
      path: '/onboarding/nickname',
      builder: (context, state) => const NicknameSetupScreen(),
    ),
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
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return FinanceSetupScreen(characterType: extra?['characterType'] as String? ?? 'ant_shopping');
      },
    ),
    GoRoute(
      path: '/onboarding/challenge-setup',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return ChallengeSetupScreen(
          characterType: extra?['characterType'] as String? ?? 'ant_shopping',
          monthlyIncome: extra?['monthlyIncome'] as int? ?? 0,
          fixedExpenses: extra?['fixedExpenses'] as int? ?? 0,
          isFromOnboarding: extra?['isFromOnboarding'] as bool? ?? true,
        );
      },
    ),
    GoRoute(
      path: '/manage-finance',
      builder: (context, state) => const ManageFinanceScreen(),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Row(
          children: [
            const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primaryDark),
            const SizedBox(width: 8),
            Text('소 리', style: AppTextStyles.pageTitle.copyWith(color: AppColors.primaryDark)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.textPrimary),
            onPressed: () {
              final uid = FirebaseAuth.instance.currentUser?.uid;
              if (uid == null) return;
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40, height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('설정', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ListTile(
                        leading: const Text('🌱', style: TextStyle(fontSize: 24)),
                        title: const Text('데모 데이터 초기화'),
                        subtitle: const Text('시연용 지출·챌린지·위험지역 데이터를 넣습니다'),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        tileColor: Colors.green.withValues(alpha: 0.06),
                        onTap: () {
                          Navigator.pop(ctx);
                          DemoService.seedDemoData(context, uid);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
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
            BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), activeIcon: Icon(Icons.pets), label: '캐릭터'),
            BottomNavigationBarItem(icon: Icon(Icons.warning_amber_rounded), activeIcon: Icon(Icons.warning_rounded), label: '위험지역'),
          ],
        ),
      ),
    );
  }
}

