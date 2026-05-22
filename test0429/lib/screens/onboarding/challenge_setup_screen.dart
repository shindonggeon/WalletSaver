import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class ChallengeSetupScreen extends StatefulWidget {
  const ChallengeSetupScreen({super.key});

  @override
  State<ChallengeSetupScreen> createState() => _ChallengeSetupScreenState();
}

class _ChallengeSetupScreenState extends State<ChallengeSetupScreen> {
  final TextEditingController _textController = TextEditingController();

  final List<Map<String, dynamic>> challenges = [
    {'title': '택시 대신 대중교통이나 자전거 타기', 'emoji': '🚲', 'selected': false},
    {'title': '배달음식 주 1회 이하로 줄이기', 'emoji': '🥗', 'selected': false},
    {'title': '이번주 의류 및 패션 잡화 쇼핑 참기', 'emoji': '🛍️', 'selected': false},
    {'title': '이번주 계획 금액 초과하지 않기', 'emoji': '💰', 'selected': false},
  ];

  void _addCustomChallenge() {
    final String text = _textController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        challenges.add({
          'title': text,
          'emoji': '🎯',
          'selected': true,
        });
        _textController.clear();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        title: Text('목표 설정', style: AppTextStyles.pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('함께 달성할\n챌린지를 골라주세요!', style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, height: 1.5)),
                  const SizedBox(height: 4),
                  Text('여러 개 선택할 수 있어요.', style: AppTextStyles.captionNormal),
                  const SizedBox(height: 28),
                  ...challenges.map((c) => _ChallengeItem(
                    challenge: c,
                    onTap: () => setState(() => c['selected'] = !c['selected']),
                  )),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, color: AppColors.textHint, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            onSubmitted: (_) => _addCustomChallenge(),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: '직접 입력하기...',
                              isDense: true,
                              fillColor: Colors.transparent,
                              filled: true,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 22),
                          onPressed: _addCustomChallenge,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('소리와 함께 시작하기'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChallengeItem extends StatelessWidget {
  final Map<String, dynamic> challenge;
  final VoidCallback onTap;
  const _ChallengeItem({required this.challenge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final bool isSelected = challenge['selected'] as bool;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.tagBg : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? AppColors.primary : AppColors.border, width: isSelected ? 1.5 : 1),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          children: [
            Text(challenge['emoji'] ?? '🎯', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                challenge['title'],
                style: AppTextStyles.bodyBold.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.primary : AppColors.border,
            ),
          ],
        ),
      ),
    );
  }
}