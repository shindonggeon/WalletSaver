import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

/// 캐릭터 카드 — 예산 상태별 애니메이션 + Progress Bar
class CharacterCard extends StatelessWidget {
  final double budgetUsageRate;
  final String? characterType;

  const CharacterCard({
    super.key,
    required this.budgetUsageRate,
    this.characterType,
  });

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.getBudgetTheme(budgetUsageRate);
    final remainPct = ((1.0 - budgetUsageRate) * 100).clamp(0.0, 100.0);
    
    // DB 데이터가 없으면 기본값(개미) 사용
    final String cType = characterType ?? 'ant_shopping';
    final charData = CharacterTypes.characterData[cType] ?? CharacterTypes.characterData['ant_shopping']!;
    final String charEmoji = charData['emoji']!;
    final String charName = charData['name']!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.primary.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.primary.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // 캐릭터 아바타
          _CharacterAvatar(emoji: charEmoji, primaryColor: theme.primary),
          const SizedBox(width: 16),
          // 상태 텍스트 + Progress Bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$charEmoji $charName',
                    style: AppTextStyles.micro.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${theme.emoji}  ${theme.label}',
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary),
                ),
                const SizedBox(height: 4),
                Text(
                  '예산 ${remainPct.toStringAsFixed(0)}% 남음',
                  style: AppTextStyles.captionNormal,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: (remainPct / 100).clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOut,
                    builder: (context, value, child) => LinearProgressIndicator(
                      value: value.clamp(0.0, 1.0),
                      minHeight: 8,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(theme.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CharacterAvatar extends StatelessWidget {
  final String emoji;
  final Color primaryColor;

  const _CharacterAvatar({required this.emoji, required this.primaryColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor.withValues(alpha: 0.2), width: 2),
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.10),
              border: Border.all(color: primaryColor.withValues(alpha: 0.35), width: 2),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(emoji, key: ValueKey(emoji), style: const TextStyle(fontSize: 40)),
          ),
        ],
      ),
    );
  }
}
