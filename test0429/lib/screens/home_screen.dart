import 'package:flutter/material.dart';
import '../widgets/character_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/challenge_card.dart';
import '../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // ── Dummy Data ──────────────────────────────────────────
  static const String nickname = '소리님';
  static const String naggingText = '"오늘 이미 커피 2잔이나 마셨어요! 또 카페 가시게요?"';
  static const int todayBudget = 15300;
  static const int monthlyBudget = 750000;
  static const int monthlyExpense = 410000;
  static const int monthlyRemaining = 340000;
  static const double budgetUsageRate = 0.55; // 0.0~1.0 (주의 상태)

  static const List<Map<String, dynamic>> recentTransactions = [
    {'title': '스타벅스 강남점', 'category': '카페', 'amount': -5500, 'time': '14:30', 'emoji': '☕'},
    {'title': 'CU 편의점', 'category': '식비', 'amount': -4200, 'time': '12:10', 'emoji': '🏪'},
    {'title': '교통카드 충전', 'category': '교통', 'amount': -30000, 'time': '08:45', 'emoji': '🚇'},
  ];
  // ────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getBudgetTheme(budgetUsageRate);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── 상단 앱바
          SliverAppBar(
            backgroundColor: AppColors.bgPage,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: false,
            floating: true,
            expandedHeight: 70,
            flexibleSpace: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_todayLabel(), style: AppTextStyles.captionNormal),
                      Text('안녕하세요, $nickname 👋', style: AppTextStyles.greetingTitle),
                    ],
                  ),
                  Row(
                    children: [
                      _IconBtn(icon: Icons.notifications_none_rounded, onTap: () {}),
                      const SizedBox(width: 8),
                      _IconBtn(icon: Icons.settings_outlined, onTap: () {}),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── 본문
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 잔소리 배너
                _NaggingBanner(text: naggingText, themeColor: theme.primary),
                const SizedBox(height: 16),

                // 캐릭터 카드
                CharacterCard(budgetUsageRate: budgetUsageRate),
                const SizedBox(height: 16),

                // 예산 Hero 카드
                BudgetCard(
                  todayBudget: todayBudget,
                  monthlyBudget: monthlyBudget,
                  monthlyExpense: monthlyExpense,
                  monthlyRemaining: monthlyRemaining,
                  budgetUsageRate: budgetUsageRate,
                ),
                const SizedBox(height: 16),

                // 챌린지 카드
                const ChallengeCard(
                  challengeName: '카페 주 3회 이하',
                  progressText: '이번주 2회 / 목표 3회',
                  isAchieving: true,
                ),
                const SizedBox(height: 20),

                // 최근 지출 섹션
                Text('최근 지출', style: AppTextStyles.sectionHeader),
                const SizedBox(height: 12),
                ...recentTransactions.map((tx) => _TransactionItem(tx: tx)),
                const SizedBox(height: 20),

                // 지출 추가 버튼
                _AddExpenseButton(primary: theme.primary),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    final day = days[now.weekday - 1];
    return '${now.year}년 ${now.month}월 ${now.day}일 $day요일';
  }
}

class _NaggingBanner extends StatelessWidget {
  final String text;
  final Color themeColor;
  const _NaggingBanner({required this.text, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, color: themeColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: themeColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: AppColors.textHint),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Map<String, dynamic> tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColors[tx['category']] ?? AppColors.textHint;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(tx['emoji'] ?? '💳', style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx['title'], style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
                Text('${tx['category']} · ${tx['time']}', style: AppTextStyles.captionNormal),
              ],
            ),
          ),
          Text(
            '${formatNumber(tx['amount'].abs())}원',
            style: AppTextStyles.bodyBold.copyWith(
              color: (tx['amount'] as int) < 0 ? AppColors.textPrimary : AppColors.income,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  final Color primary;
  const _AddExpenseButton({required this.primary});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text('지출 추가하기', style: AppTextStyles.button),
        ],
      ),
    );
  }
}
