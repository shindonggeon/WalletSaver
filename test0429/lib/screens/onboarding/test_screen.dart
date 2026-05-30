import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../constants/app_constants.dart';
import '../../theme/app_theme.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  int _currentStep = 0;
  final List<int> _answerScores = List.filled(17, 0);
  String _selectedInterest = CategoryKeys.shopping;

  final List<Map<String, dynamic>> _questions = [
    {'text': '나는 사고 싶은 것이 생기면 깊게 고민하지 않고 바로 구매하는 편이다.', 'type': 'impulsive'},
    {'text': '기분이 좋거나 스트레스를 받으면 소비가 늘어나는 편이다.', 'type': 'impulsive'},
    {'text': '원래 살 계획이 없던 물건이나 서비스를 즉흥적으로 구매한 적이 많다.', 'type': 'impulsive'},
    {'text': '소비하기 전에 예산이나 사용 목적을 먼저 생각하는 편이다.', 'type': 'planned'},
    {'text': '큰 지출이 예상되면 미리 계획을 세워 준비하는 편이다.', 'type': 'planned'},
    {'text': '구매 전 가격, 후기, 필요성을 비교해보는 편이다.', 'type': 'planned'},
    {'text': '물건을 살 때 꼭 필요한지 여러 번 생각하는 편이다.', 'type': 'saving'},
    {'text': '지출을 줄일 수 있다면 다소 불편해도 감수할 수 있는 편이다.', 'type': 'saving'},
    {'text': '소비보다 저축이나 지출 관리에 더 우선순위를 두는 편이다.', 'type': 'saving'},
    {'text': '나는 옷, 신발, 가방 등 패션 관련 소비 비중이 높은 편이다.', 'type': 'shopping'},
    {'text': '스타일이나 외적인 만족을 위해 의류에 돈을 쓰는 편이다.', 'type': 'shopping'},
    {'text': '여행, 카페, 전시, 공연 등 외부 활동에 돈을 자주 쓰는 편이다.', 'type': 'leisure'},
    {'text': '물건보다 경험(여행, 전시회 등)에 더 가치를 두는 편이다.', 'type': 'leisure'},
    {'text': '게임, 술자리 등 나를 즐겁게 하는 소비를 자주 하는 편이다.', 'type': 'self_satisfaction'},
    {'text': '나를 만족시키는 소비라면 비용이 어느 정도 들어도 괜찮다고 생각한다.', 'type': 'self_satisfaction'},
    {'text': '배달, 택시, 구독 서비스 등 편의를 위한 소비가 많은 편이다.', 'type': 'convenience'},
    {'text': '시간과 노력을 줄이기 위해 돈을 쓰는 편이다.', 'type': 'convenience'},
  ];

  final List<Map<String, String>> _interestOptions = [
    {'label': '쇼핑', 'value': CategoryKeys.shopping},
    {'label': '여가', 'value': CategoryKeys.leisure},
    {'label': '자기만족', 'value': CategoryKeys.selfSatisfaction},
    {'label': '편의생활', 'value': CategoryKeys.convenience},
  ];

  void _handleScoreAnswer(int scoreValue) {
    setState(() {
      _answerScores[_currentStep] = scoreValue;
      _currentStep++;
    });
  }

  void _handleFinalCategory(String categoryValue) {
    setState(() {
      _selectedInterest = categoryValue;
    });
    _calculateFinalResult();
  }

  void _calculateFinalResult() {
    int impulsiveScore = _answerScores[0] + _answerScores[1] + _answerScores[2];
    int plannedScore = _answerScores[3] + _answerScores[4] + _answerScores[5];
    int savingScore = _answerScores[6] + _answerScores[7] + _answerScores[8];

    int maxTraitScore = [impulsiveScore, plannedScore, savingScore].reduce((a, b) => a > b ? a : b);
    List<String> tiedTraits = [];
    
    if (impulsiveScore == maxTraitScore) tiedTraits.add(CharacterTypes.lion);
    if (plannedScore == maxTraitScore) tiedTraits.add(CharacterTypes.ant);
    if (savingScore == maxTraitScore) tiedTraits.add(CharacterTypes.turtle);

    String finalTrait = CharacterTypes.ant;

    if (tiedTraits.length == 1) {
      finalTrait = tiedTraits.first;
    } else if (tiedTraits.length == 3) {
      if (maxTraitScore == 0) {
        finalTrait = CharacterTypes.turtle; 
      } else {
        finalTrait = CharacterTypes.lion;
      }
    } else {
      if (tiedTraits.contains(CharacterTypes.lion) && tiedTraits.contains(CharacterTypes.ant)) {
        finalTrait = CharacterTypes.lion;
      } else if (tiedTraits.contains(CharacterTypes.lion) && tiedTraits.contains(CharacterTypes.turtle)) {
        finalTrait = CharacterTypes.lion;
      } else if (tiedTraits.contains(CharacterTypes.ant) && tiedTraits.contains(CharacterTypes.turtle)) {
        int q8Score = _answerScores[7];
        if (q8Score == 3 || q8Score == 4) {
          finalTrait = CharacterTypes.turtle;
        } else {
          finalTrait = CharacterTypes.ant;
        }
      }
    }

    Map<String, int> catScores = {
      CategoryKeys.shopping: _answerScores[9] + _answerScores[10],
      CategoryKeys.leisure: _answerScores[11] + _answerScores[12],
      CategoryKeys.selfSatisfaction: _answerScores[13] + _answerScores[14],
      CategoryKeys.convenience: _answerScores[15] + _answerScores[16],
    };

    catScores[_selectedInterest] = catScores[_selectedInterest]! + 2;

    int maxCatScore = catScores.values.reduce((a, b) => a > b ? a : b);
    List<String> tiedCats = [];
    catScores.forEach((cat, score) {
      if (score == maxCatScore) tiedCats.add(cat);
    });

    String finalCategory = CategoryKeys.shopping;

    if (tiedCats.length == 1) {
      finalCategory = tiedCats.first;
    } else {
      if (tiedCats.contains(_selectedInterest)) {
        finalCategory = _selectedInterest;
      } else {
        Map<String, int> maxSingleScores = {
          CategoryKeys.shopping: _answerScores[9] > _answerScores[10] ? _answerScores[9] : _answerScores[10],
          CategoryKeys.leisure: _answerScores[11] > _answerScores[12] ? _answerScores[11] : _answerScores[12],
          CategoryKeys.selfSatisfaction: _answerScores[13] > _answerScores[14] ? _answerScores[13] : _answerScores[14],
          CategoryKeys.convenience: _answerScores[15] > _answerScores[16] ? _answerScores[15] : _answerScores[16],
        };

        int highestSingleValue = -1;
        List<String> step2TiedCats = [];

        for (var cat in tiedCats) {
          int singleMax = maxSingleScores[cat]!;
          if (singleMax > highestSingleValue) {
            highestSingleValue = singleMax;
            step2TiedCats = [cat];
          } else if (singleMax == highestSingleValue) {
            step2TiedCats.add(cat);
          }
        }

        if (step2TiedCats.length == 1) {
          finalCategory = step2TiedCats.first;
        } else {
          List<String> priorityOrder = [
            CategoryKeys.shopping,
            CategoryKeys.leisure,
            CategoryKeys.selfSatisfaction,
            CategoryKeys.convenience
          ];
          for (var pCat in priorityOrder) {
            if (step2TiedCats.contains(pCat)) {
              finalCategory = pCat;
              break;
            }
          }
        }
      }
    }

    final String combinedResultCode = '${finalTrait}_$finalCategory';

    if (mounted) {
      context.push('/onboarding/result', extra: combinedResultCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double progress = (_currentStep + 1) / 18.0;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 20),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() {
                _currentStep--;
              });
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          '소비 성향 테스트 (${_currentStep + 1}/18)',
          style: AppTextStyles.bodyBold.copyWith(fontSize: 16),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.tagBg,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 6,
                borderRadius: BorderRadius.circular(3),
              ),
              const SizedBox(height: 60),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: IntrinsicHeight(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Q${_currentStep + 1}',
                                      style: AppTextStyles.greetingTitle.copyWith(
                                        color: AppColors.primary,
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(height: 24),
                                    Text(
                                      _currentStep < 17 
                                          ? _questions[_currentStep]['text']! 
                                          : '가장 관심 있는 소비 카테고리를 하나 선택해주세요. (선택한 카테고리 +2점)',
                                      textAlign: TextAlign.center,
                                      style: AppTextStyles.greetingTitle.copyWith(
                                        fontSize: 20,
                                        height: 1.5,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 32),
                              _currentStep < 17 
                                  ? _buildLikertButtons() 
                                  : _buildCategoryButtons(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLikertButtons() {
    final List<Map<String, dynamic>> likertOptions = [
      {'text': '매우 그렇다', 'score': 4},
      {'text': '그렇다', 'score': 3},
      {'text': '보통이다', 'score': 2},
      {'text': '아니다', 'score': 1},
      {'text': '전혀 아니다', 'score': 0},
    ];

    return Column(
      children: likertOptions.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () => _handleScoreAnswer(opt['score']),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              side: const BorderSide(color: AppColors.tagBg, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(opt['text'], style: AppTextStyles.bodyBold.copyWith(fontSize: 15)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCategoryButtons() {
    return Column(
      children: _interestOptions.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: ElevatedButton(
            onPressed: () => _handleFinalCategory(opt['value']!),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              padding: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(opt['label']!, style: AppTextStyles.bodyBold.copyWith(fontSize: 16, color: Colors.white)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}