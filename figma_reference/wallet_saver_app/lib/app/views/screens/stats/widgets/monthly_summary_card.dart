import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class MonthlySummaryCard extends StatelessWidget {
  const MonthlySummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('이번 달 요약', style: AppTextStyles.pageTitle),
              const Icon(Icons.calendar_today, color: AppColors.textHint, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          _buildSummaryRow('총 수입', '+ 1,000,000 원', AppColors.income),
          const SizedBox(height: 12),
          _buildSummaryRow('총 지출', '- 170,200 원', AppColors.expense),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.divider),
          ),
          _buildSummaryRow('순 잔액', '829,800 원', AppColors.primary, isBold: true),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: AppColors.textHint),
        ),
        Text(
          value,
          style: isBold 
            ? AppTextStyles.pageTitle.copyWith(color: valueColor)
            : AppTextStyles.body.copyWith(color: valueColor, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
