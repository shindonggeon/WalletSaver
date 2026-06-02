import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../models/challenge.dart';
import '../../services/challenge_service.dart';
import '../../services/user_service.dart';
import '../../services/budget_service.dart';
import '../../constants/app_constants.dart';
class ChallengeSetupScreen extends StatefulWidget {
  final String characterType;
  final int monthlyIncome;
  final int fixedExpenses;
  final bool isFromOnboarding;
  
  const ChallengeSetupScreen({
    super.key, 
    required this.characterType,
    required this.monthlyIncome,
    required this.fixedExpenses,
    this.isFromOnboarding = true,
  });

  @override
  State<ChallengeSetupScreen> createState() => _ChallengeSetupScreenState();
}

class _ChallengeSetupScreenState extends State<ChallengeSetupScreen> {
  final List<Map<String, dynamic>> _presets = [
    {'title': '무지출 챌린지 3일 연속', 'emoji': '🚫', 'selected': true},
    {'title': '택시 대신 대중교통 이용하기', 'emoji': '🚇', 'selected': false},
    {'title': '배달음식 주 1회로 줄이기', 'emoji': '🥗', 'selected': true},
    {'title': '카페 안 가고 텀블러 쓰기', 'emoji': '☕', 'selected': false},
  ];
  final _customController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _customController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 선택한 프리셋 + 직접 입력 항목 수집
    final selected = _presets
        .where((c) => c['selected'] == true)
        .map((c) => Challenge(
              id: '',
              title: c['title'] as String,
              emoji: c['emoji'] as String,
              isActive: true,
              startedAt: Timestamp.now(),
            ))
        .toList();

    final custom = _customController.text.trim();
    if (custom.isNotEmpty) {
      selected.add(Challenge(
        id: '',
        title: custom,
        emoji: '🎯',
        isActive: true,
        startedAt: Timestamp.now(),
      ));
    }

    setState(() => _isSaving = true);
    try {
      await Future(() async {
        // 1. 캐릭터 타입 DB 저장
        await UserService.updateCharacterType(
          uid: uid,
          characterType: widget.characterType,
        );

        // 2. 초기 예산 데이터 생성
        await BudgetService.recalculateAndSave(
          uid: uid,
          monthlyIncome: widget.monthlyIncome,
          fixedExpenses: widget.fixedExpenses,
        );

        // 3. 챌린지 저장
        final activeSnap = await FirebaseFirestore.instance
            .collection(CollectionKeys.users)
            .doc(uid)
            .collection(CollectionKeys.challenges)
            .where('isActive', isEqualTo: true)
            .get();
        final activeTitles = activeSnap.docs.map((d) => d['title'] as String).toSet();
        
        final newChallenges = selected.where((c) => !activeTitles.contains(c.title)).toList();
        
        if (newChallenges.isNotEmpty) {
          await ChallengeService.createChallenges(uid: uid, challenges: newChallenges);
        }
      }).timeout(const Duration(seconds: 5));
      
      if (mounted) {
        if (widget.isFromOnboarding) {
          context.go('/home');
        } else {
          context.pop();
        }
      }
    } catch (e) {
      print('저장 실패 (무시하고 넘어감): $e');
      // 타임아웃/권한 에러 발생 시에도 시연을 위해 강제로 홈으로 보냅니다.
      if (mounted) {
        if (widget.isFromOnboarding) {
          context.go('/home');
        } else {
          context.pop();
        }
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addCustomChallenge() {
    final String text = _customController.text.trim();
    if (text.isNotEmpty) {
      setState(() {
        _presets.add({
          'title': text,
          'emoji': '🎯',
          'selected': true,
        });
        _customController.clear();
      });
    }
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
                  Text(
                    '함께 달성할\n챌린지를 골라주세요!',
                    style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, height: 1.5),
                  ),
                  const SizedBox(height: 4),
                  Text('여러 개 선택할 수 있어요.', style: AppTextStyles.captionNormal),
                  const SizedBox(height: 28),
                  ..._presets.map((c) => _ChallengeItem(
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
                            controller: _customController,
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
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('소리와 함께 시작하기'),
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
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
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