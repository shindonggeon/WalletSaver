import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const String charEmoji = '🐿️';
  static const String charName = '알뜰한 다람쥐';
  static const String charDesc = '도토리를 모으듯 차곡차곡 예산을 아끼는 당신!\n가끔은 너무 아껴서 스트레스 받을 수도 있어요.';
  static const String soriComment = '"다람쥐님, 저와 함께 목표까지 달려봐요!"';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),
              Text('당신의 소비 성향은...', style: AppTextStyles.captionNormal, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              // 결과 카드 (그라디언트)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.gradFrom, AppColors.gradTo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: Column(
                  children: [
                    Text(charEmoji, style: const TextStyle(fontSize: 72)),
                    const SizedBox(height: 20),
                    Text(charName, style: AppTextStyles.greetingTitle.copyWith(color: Colors.white, fontSize: 24)),
                    const SizedBox(height: 12),
                    Text(charDesc, textAlign: TextAlign.center, style: AppTextStyles.body.copyWith(color: Colors.white70, height: 1.6)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 소리 코멘트
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.tagBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.record_voice_over, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(child: Text(soriComment, style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary))),
                  ],
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => context.push('/onboarding/finance-setup'),
                child: const Text('재무 설정하러 가기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
