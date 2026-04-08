import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../controllers/budget_controller.dart';
import '../../../controllers/nav_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'widgets/character_card.dart';
import 'widgets/budget_hero_card.dart';
import 'widgets/nag_alert_card.dart';
import 'widgets/recent_transactions.dart';

/// 홈 메인 화면
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final budgetCtrl = Get.find<BudgetController>();
    final navCtrl = Get.find<NavController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F3FF),
      body: Obx(() {
        final theme = budgetCtrl.theme;

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 상단 앱바 ──────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF5F3FF),
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
                        Text(
                          _todayLabel(),
                          style: AppTextStyles.captionNormal,
                        ),
                        Text(
                          '안녕하세요, 소리님 👋',
                          style: AppTextStyles.greetingTitle,
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        // 알림 버튼
                        _IconButton(
                          icon: Icons.notifications_none_rounded,
                          onTap: () {},
                        ),
                        const SizedBox(width: 8),
                        // 설정 버튼
                        _IconButton(
                          icon: Icons.settings_outlined,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── 본문 ───────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // AI 잔소리 알림
                  const NagAlertCard(),
                  const SizedBox(height: 16),

                  // 캐릭터 카드
                  const CharacterCard(),
                  const SizedBox(height: 16),

                  // 예산 Hero 카드
                  const BudgetHeroCard(),
                  const SizedBox(height: 20),

                  // 챌린지 카드 (소형)
                  _ChallengeCard(themeColor: theme.primary),
                  const SizedBox(height: 20),

                  // 최근 지출 리스트
                  const RecentTransactions(),
                  const SizedBox(height: 20),

                  // 빠른 지출 추가 버튼
                  _AddExpenseButton(
                    primary: theme.primary,
                    onTap: () => navCtrl.changeTo(1),
                  ),
                ]),
              ),
            ),
          ],
        );
      }),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    final day = days[now.weekday - 1];
    return '${now.year}년 ${now.month}월 ${now.day}일 $day요일';
  }
}

// ── 상단 아이콘 버튼 ──────────────────────────────────────────
class _IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _IconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.textHint),
      ),
    );
  }
}

// ── 챌린지 카드 ───────────────────────────────────────────────
class _ChallengeCard extends StatelessWidget {
  final Color themeColor;

  const _ChallengeCard({required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF7ED),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '카페 주 3회 이하',
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '이번주 2회 / 목표 3회',
                  style: AppTextStyles.captionNormal,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '달성 중 ✓',
              style: AppTextStyles.caption.copyWith(
                color: const Color(0xFF22C55E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 빠른 지출 추가 버튼 ───────────────────────────────────────
class _AddExpenseButton extends StatelessWidget {
  final Color primary;
  final VoidCallback onTap;

  const _AddExpenseButton({required this.primary, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
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
            BoxShadow(
              color: primary.withValues(alpha: 0.45),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
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
      ),
    );
  }
}
