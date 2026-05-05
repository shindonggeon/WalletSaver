import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  static const int currentStep = 1;
  static const int totalSteps = 6;
  static const String questionTitle = '친구들과 저녁 약속이 생겼을 때, 당신의 행동은?';
  static const String optionA = 'A  "맛있는 거 먹자!" 비싸도 쿨하게 콜';
  static const String optionB = 'B  "어디 가지? 가성비 좋은 곳을 먼저 찾아본다."';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 진행바
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentStep / totalSteps,
                      backgroundColor: AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text('$currentStep / $totalSteps', style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 40),
            Text(
              'Q$currentStep.',
              style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(questionTitle, style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, height: 1.5)),
            const Spacer(),
            _OptionButton(text: optionA, onTap: () => context.push('/onboarding/result')),
            const SizedBox(height: 14),
            _OptionButton(text: optionB, onTap: () => context.push('/onboarding/result')),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _OptionButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _OptionButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Text(text, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary, fontSize: 15), textAlign: TextAlign.center),
      ),
    );
  }
}
