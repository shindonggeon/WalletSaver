import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/expense_controller.dart';
import '../../../../controllers/nav_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/expense_model.dart';

/// 최근 지출 내역 리스트 섹션
class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ExpenseController>();
    final navCtrl = Get.find<NavController>();

    return Obx(() {
      final recent = ctrl.recentExpenses(count: 4);

      return Column(
        children: [
          // ── 섹션 헤더 ──────────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('최근 지출', style: AppTextStyles.sectionHeader),
              GestureDetector(
                onTap: () => navCtrl.changeTo(2), // 통계 탭으로
                child: Row(
                  children: [
                    Text(
                      '전체보기',
                      style: AppTextStyles.captionNormal.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // ── 거래 리스트 카드 ───────────────────────────────
          Container(
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
            child: recent.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        '아직 지출 내역이 없어요 😊',
                        style: AppTextStyles.body,
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recent.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: AppColors.divider,
                      indent: 16,
                      endIndent: 16,
                    ),
                    itemBuilder: (_, i) =>
                        _TransactionTile(expense: recent[i]),
                  ),
          ),
        ],
      );
    });
  }
}

class _TransactionTile extends StatelessWidget {
  final ExpenseModel expense;

  const _TransactionTile({required this.expense});

  @override
  Widget build(BuildContext context) {
    final catColor =
        AppColors.categoryColors[expense.category] ?? AppColors.textHint;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // ── 카테고리 아이콘 ────────────────────────────────
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                expense.icon,
                style: const TextStyle(fontSize: 22),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ── 이름 + 시간 ────────────────────────────────────
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.name, style: AppTextStyles.listTitle),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _timeLabel(expense.date),
                      style: AppTextStyles.captionNormal,
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        expense.category,
                        style: AppTextStyles.micro.copyWith(
                          color: catColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── 금액 ──────────────────────────────────────────
          Text(
            _amountText(expense),
            style: AppTextStyles.bodyBold.copyWith(
              color: expense.isIncome
                  ? AppColors.income
                  : AppColors.expense,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _timeLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date).inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    return '${diff}일 전';
  }

  String _amountText(ExpenseModel e) {
    final abs = e.absAmount;
    final s = abs.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return e.isIncome ? '+${buf}원' : '-${buf}원';
  }
}
