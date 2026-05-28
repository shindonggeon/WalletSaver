import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  static const Map<String, Map<String, String>> _characterData = {
    'lion_shopping': {
      'name': '즉흥적인 쇼퍼',
      'desc': '즉흥적인 쇼퍼 유형입니다! 장바구니에 담아두고 하룻밤 더 고민하는 습관을 가져보세요.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'lion_convenience': {
      'name': '즉흥적인 편의주의자',
      'desc': '즉흥적인 편의주의자 유형이네요! 편리함에 익숙해져 새나가는 지출을 막기 위해 직접 움직이는 연습이 필요합니다.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'lion_leisure': {
      'name': '즉흥적인 여행가',
      'desc': '즉흥적인 여행가 유형입니다! 즐거운 여가 뒤에 오는 지출이 부담되지 않도록 전용 비상금을 운용해 보세요.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'lion_self_satisfaction': {
      'name': '즉흥적인 하비슈머',
      'desc': '즉흥적인 하비슈머 유형이네요! 한꺼번에 많은 비용을 쏟기보다 취미생활의 깊이를 천천히 더해가며 지출을 조절해 보세요.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'ant_shopping': {
      'name': '계획적인 쇼퍼',
      'desc': '계획적인 쇼퍼 유형이네요! 정해진 예산 안에서 최선의 선택을 내리는 모습이 아주 훌륭합니다!',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png', 
    },
    'ant_convenience': {
      'name': '계획적인 편의주의자',
      'desc': '계획적인 편의주의자 유형입니다! 서비스 활용도와 효율성이 매우 높네요. 지금처럼 스마트하게 관리하시면 됩니다!',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png',
    },
    'ant_leisure': {
      'name': '계획적인 여행가',
      'desc': '계획적인 여행가 유형이네요! 철저한 사전 조사 and 준비성 덕분에 항상 알찬 여가를 보내고 계시군요. 정말 멋집니다!',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png',
    },
    'ant_self_satisfaction': {
      'name': '계획적인 하비슈머',
      'desc': '계획적인 하비슈머 유형입니다! 취미 생활조차 체계적으로 조절하는 절제력이 대단하네요. 지금의 페이스를 유지하세요!',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png',
    },
    'turtle_shopping': {
      'name': '알뜰한 쇼퍼',
      'desc': '알뜰한 쇼퍼 유형입니다! 무조건 저렴한 것만 찾기보다 오래 입을 수 있는 옷에 투자하는 합리적 소비도 고려해 보세요.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png', 
    },
    'turtle_convenience': {
      'name': '알뜰한 편의주의자',
      'desc': '알뜰한 편의주의자 유형이네요! 지출을 아끼는 것도 좋지만, 가끔은 우리 주변의 편리한 시스템을 적절히 이용해 일상의 여유와 효율을 챙겨보세요.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png',
    },
    'turtle_leisure': {
      'name': '알뜰한 여행가',
      'desc': '알뜰한 여행가 유형입니다! 비용을 줄이는 데만 몰두하기보다 본인의 즐거움을 위해 적당한 여가 생활을 누려보세요.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png',
    },
    'turtle_self_satisfaction': {
      'name': '알뜰한 하비슈머',
      'desc': '알뜰한 하비슈머 유형이네요! 비용을 아끼는 것도 좋지만 취미의 질을 높여줄 핵심적인 부분에는 적당히 지출해 보는 것도 추천합니다.',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png',
    },
  };

  @override
  Widget build(BuildContext context) {
    String combinedCode = 'ant_shopping';
    try {
      final state = GoRouterState.of(context);
      if (state.extra is String) {
        combinedCode = state.extra as String;
      }
    } catch (_) {}

    final currentCharacter = _characterData[combinedCode] ?? _characterData['ant_shopping']!;

    final animalType = combinedCode.split('_')[0];

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 48),
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

                    /* 추후 Lottie 이미지로 교체 시
                    
                    Lottie.asset(
                      'assets/animations/characters/$animalType.json', // 👈 lion, ant, turtle 중 하나로 자동 매핑!
                      height: 140,
                      fit: BoxFit.contain,
                      animate: true,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.emoji_emotions_outlined, size: 80, color: Colors.white),
                    ),
                    */

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
    );
  }
}