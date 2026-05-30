import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});



  @override
  Widget build(BuildContext context) {
    String combinedCode = 'ant_shopping';
    try {
      final state = GoRouterState.of(context);
      if (state.extra is String) {
        combinedCode = state.extra as String;
      }
    } catch (_) {}

    final currentCharacter = CharacterTypes.characterData[combinedCode] ?? CharacterTypes.characterData['ant_shopping']!;

    final animalType = combinedCode.split('_')[0];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 24),
                      Text(
                        '분석을 통해 도출된 당신의 소비 성향 유형',
                        style: AppTextStyles.captionNormal.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.gradFrom, AppColors.gradTo],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            )
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              currentCharacter['name']!,
                              style: AppTextStyles.greetingTitle.copyWith(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: 40,
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(height: 24),

                            // 임시 이미지
                            Image.network(
                              currentCharacter['imageUrl']!,
                              height: 140,
                              fit: BoxFit.contain,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const SizedBox(
                                  height: 140,
                                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.emoji_emotions_outlined, size: 80, color: Colors.white),
                            ),

                            const SizedBox(height: 24),
                            Text(
                              currentCharacter['desc']!,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.body.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                fontSize: 15,
                                height: 1.6,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/onboarding/finance-setup', extra: {'characterType': combinedCode});
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          '재무 설정하러 가기',
                          style: AppTextStyles.bodyBold.copyWith(fontSize: 16, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
      ),
    );
  }
}