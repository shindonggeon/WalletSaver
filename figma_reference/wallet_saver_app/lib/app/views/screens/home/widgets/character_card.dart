import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import '../../../../controllers/budget_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../data/models/budget_state.dart';

/// 캐릭터 카드 위젯
/// - Lottie 애니메이션 영역 (현재: 이모지 placeholder)
/// - 예산 상태 텍스트
/// - Progress Bar
class CharacterCard extends StatelessWidget {
  const CharacterCard({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BudgetController>();

    return Obx(() {
      final theme = ctrl.theme;
      final state = ctrl.budgetState;
      final pct = ctrl.remainPct;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: Colors.white,
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
            // ── Lottie / 캐릭터 영역 ─────────────────────────
            _CharacterAvatar(state: state, primaryColor: theme.primary),
            const SizedBox(width: 16),

            // ── 상태 텍스트 + Progress Bar ───────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // MBTI 타입 칩
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '🐿️ 충동적 다람쥐',
                      style: AppTextStyles.micro.copyWith(
                        color: theme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 상태 라벨 (AnimatedSwitcher로 전환)
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Align(
                      key: ValueKey(state),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${theme.emoji}  ${theme.label}',
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '예산 ${pct.toStringAsFixed(0)}% 남음',
                    style: AppTextStyles.captionNormal,
                  ),
                  const SizedBox(height: 10),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: pct / 100),
                      duration: const Duration(milliseconds: 800),
                      curve: Curves.easeOut,
                      builder: (_, value, __) {
                        return LinearProgressIndicator(
                          value: value,
                          minHeight: 8,
                          backgroundColor: AppColors.border,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.primary,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 캐릭터 아바타 (Lottie placeholder → 추후 Lottie JSON으로 교체)
class _CharacterAvatar extends StatelessWidget {
  final BudgetState state;
  final Color primaryColor;

  const _CharacterAvatar({
    required this.state,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final emoji = budgetThemeMap[state]!.emoji;

    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 외부 Glow Ring
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
          ),
          // 내부 Ring + 배경
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: primaryColor.withValues(alpha: 0.10),
              border: Border.all(
                color: primaryColor.withValues(alpha: 0.35),
                width: 2,
              ),
            ),
          ),
          // 이모지 캐릭터 (추후 Lottie로 교체)
          // TODO: Lottie JSON 파일 준비 시 아래 주석 해제 후 Text 위젯 제거
          // Lottie.asset(
          //   'assets/animations/character_${state.name}.json',
          //   width: 56,
          //   height: 56,
          //   repeat: true,
          // ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: FadeTransition(opacity: anim, child: child),
            ),
            child: Text(
              emoji,
              key: ValueKey(state),
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ],
      ),
    );
  }
}
