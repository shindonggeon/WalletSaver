import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../controllers/budget_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// AI 잔소리 알림 카드
/// 예산 상태가 바뀌면 메시지가 AnimatedSwitcher로 교체됨
class NagAlertCard extends StatefulWidget {
  const NagAlertCard({super.key});

  @override
  State<NagAlertCard> createState() => _NagAlertCardState();
}

class _NagAlertCardState extends State<NagAlertCard> {
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<BudgetController>();

    if (!_visible) return const SizedBox.shrink();

    return Obx(() {
      final theme = ctrl.theme;
      final state = ctrl.budgetState;

      return AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: theme.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.primary.withValues(alpha: 0.30),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 로봇 이모지 (흔들림 효과)
            const Text('🤖', style: TextStyle(fontSize: 22)),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '소리의 잔소리',
                    style: AppTextStyles.micro.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 메시지 AnimatedSwitcher
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: Text(
                      key: ValueKey(state),
                      ctrl.theme.nagMessage,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.textHint,
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 닫기 버튼
            GestureDetector(
              onTap: () => setState(() => _visible = false),
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.textHint,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
