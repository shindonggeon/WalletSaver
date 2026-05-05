import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 챌린지 카드 — 0405 디자인 스타일
class ChallengeCard extends StatelessWidget {
  final String challengeName;
  final String progressText;
  final bool isAchieving;

  const ChallengeCard({
    super.key,
    required this.challengeName,
    required this.progressText,
    this.isAchieving = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
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
            child: const Center(child: Text('🎯', style: TextStyle(fontSize: 22))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challengeName,
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 2),
                Text(progressText, style: AppTextStyles.captionNormal),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAchieving ? const Color(0xFFF0FDF4) : const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isAchieving ? '달성 중 ✓' : '도전 중',
              style: AppTextStyles.caption.copyWith(
                color: isAchieving ? const Color(0xFF22C55E) : AppColors.stateDanger,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
