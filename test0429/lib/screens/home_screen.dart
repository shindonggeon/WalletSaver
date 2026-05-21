import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/character_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/challenge_card.dart';
import '../theme/app_theme.dart';
import '../services/budget_service.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../constants/app_constants.dart';

// Number format helper (간단한 구현)
String formatNumber(int n) =>
    n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const String nickname = '소리님';
  static const String naggingText = '"오늘 이미 커피 2잔이나 마셨어요! 또 카페 가시게요?"';

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: StreamBuilder<Budget?>(
        stream: BudgetService.budgetStream(uid),
        builder: (context, budgetSnap) {
          final budget = budgetSnap.data;
          final budgetUsageRate = (budget?.budgetUsageRate ?? 0) / 100.0;
          final theme = AppTheme.getBudgetTheme(budgetUsageRate);

          return StreamBuilder<List<Expense>>(
            stream: BudgetService.expenseStream(uid),
            builder: (context, expenseSnap) {
              final expenses = expenseSnap.data ?? [];
              final recentTransactions = expenses.take(3).toList();

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
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

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _NaggingBanner(text: naggingText, themeColor: theme.primary),
                        const SizedBox(height: 16),

                        CharacterCard(budgetUsageRate: budgetUsageRate),
                        const SizedBox(height: 16),

                        BudgetCard(
                          todayBudget: budget?.todayBudget ?? 0,
                          monthlyBudget: budget?.totalBudget ?? 2500000,
                          monthlyExpense: budget?.totalSpent ?? 0,
                          monthlyRemaining: budget?.remainingBudget ?? 0,
                          budgetUsageRate: budgetUsageRate,
                        ),
                        const SizedBox(height: 16),

                        const ChallengeCard(
                          challengeName: '카페 주 3회 이하',
                          progressText: '이번주 2회 / 목표 3회',
                          isAchieving: true,
                        ),
                        const SizedBox(height: 20),

                        Text('최근 지출', style: AppTextStyles.sectionHeader),
                        const SizedBox(height: 12),
                        if (recentTransactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('이번 달 지출 내역이 없습니다.', style: TextStyle(color: AppColors.textHint))),
                          )
                        else
                          ...recentTransactions.map((tx) => _TransactionItem(tx: tx)),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            // TODO: Add Expense Flow (LedgerScreen 참고)
                          },
                          child: _AddExpenseButton(primary: theme.primary),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            }
          );
        }
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
  final Expense tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColors[tx.category] ?? AppColors.textHint;
    final catLabel = CategoryKeys.label(tx.category);
    final date = tx.spentAt.toDate();
    final timeStr = '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';

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
            child: Text(catLabel.substring(0,1), style: TextStyle(fontSize: 22, color: catColor)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.merchant, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
                Text('$catLabel · $timeStr', style: AppTextStyles.captionNormal),
              ],
            ),
          ),
          Text(
            '-${formatNumber(tx.amount)}원',
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.expense,
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
