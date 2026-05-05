import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/budget_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 예산 Hero 카드 — "오늘 쓸 수 있는 돈" 메인 그라디언트 카드
class BudgetHeroCard extends StatelessWidget {
  const BudgetHeroCard({super.key});

  static const int _monthlyBudget = 750000;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BudgetController>();

    return Obx(() {
      final theme = ctrl.theme;
      final daily = ctrl.dailyBudget;
      final remaining = ctrl.remaining;
      final spent = _monthlyBudget - remaining;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [theme.gradFrom, theme.gradTo],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: theme.primary.withValues(alpha: 0.40),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 상단: 라벨 ────────────────────────────────────
            Text(
              '오늘 쓸 수 있는 돈',
              style: AppTextStyles.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),

            // ── 메인 금액 (AnimatedSwitcher) ──────────────────
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, anim) => FadeTransition(
                opacity: anim,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(anim),
                  child: child,
                ),
              ),
              child: Align(
                key: ValueKey(daily),
                alignment: Alignment.centerLeft,
                child: Text(
                  '${_formatNumber(daily)}원',
                  style: AppTextStyles.heroAmount,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ── 하단: 3칸 요약 ────────────────────────────────
            Row(
              children: [
                _SummaryTile(
                  label: '이번달 예산',
                  value: _formatManWon(_monthlyBudget),
                ),
                _VerticalDivider(),
                _SummaryTile(
                  label: '지출',
                  value: _formatManWon(spent),
                ),
                _VerticalDivider(),
                _SummaryTile(
                  label: '잔여',
                  value: _formatManWon(remaining),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  String _formatNumber(int n) {
    final s = n.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buffer.write(',');
      buffer.write(s[i]);
    }
    return buffer.toString();
  }

  String _formatManWon(int n) {
    final man = n / 10000;
    return '${man.toStringAsFixed(1)}만원';
  }
}

class _SummaryTile extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTextStyles.micro.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: AppTextStyles.caption.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.white.withValues(alpha: 0.20),
    );
  }
}
