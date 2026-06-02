import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import '../services/challenge_service.dart';
import '../models/challenge.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';

class CharacterScreen extends StatefulWidget {
  const CharacterScreen({super.key});

  @override
  State<CharacterScreen> createState() => _CharacterScreenState();
}

class _CharacterScreenState extends State<CharacterScreen> {
  Future<List<double>>? _pastMonthsFuture;
  late String _uid;
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final user = context.watch<User?>();
      if (user != null) {
        _uid = user.uid;
        _pastMonthsFuture = BudgetService.getPast4MonthsExpenses(_uid);
        _isInit = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).snapshots(),
        builder: (context, userSnap) {
          if (!userSnap.hasData) return const Center(child: CircularProgressIndicator());
          
          final userData = userSnap.data!.data() as Map<String, dynamic>? ?? {};
          final characterType = userData['characterType'] as String? ?? 'ant_shopping';
          final charLevel = userData['level'] as int? ?? 1;
          final charXp = userData['exp'] as int? ?? 0;
          final charInfo = CharacterTypes.characterData[characterType] ?? CharacterTypes.characterData['ant_shopping']!;
          final charEmoji = charInfo['emoji'] ?? '🐜';
          final charName = charInfo['name'] ?? '알뜰한 개미';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0, left: 20, right: 20, bottom: 20),
                  child: Text('내 캐릭터', style: AppTextStyles.pageTitle),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileCard(charEmoji, charName, charLevel, charXp, userData),
                    const SizedBox(height: 16),
                    _buildBadgeCollection(charLevel),
                    const SizedBox(height: 16),
                    _buildStatsRow(uid),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.push('/manage-finance');
                        },
                        icon: const Icon(Icons.account_balance_wallet_outlined, size: 20),
                        label: const Text('고정 지출 및 수입 관리'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text('나의 목표 (챌린지) 관리', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 12),
                    _buildGoalsCard(context, uid, userData),
                    const SizedBox(height: 24),
                    Text('지출 리포트', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 12),
                    _buildChartsCard(uid),
                  ]),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildProfileCard(String emoji, String name, int level, int xp, Map<String, dynamic> userData) {
    final requiredXp = level * 20 + 10;
    final progress = (xp / requiredXp).clamp(0.0, 1.0);
    
    // 칭호 결정
    String title = '🌱 초보 절약러';
    if (level >= 10) title = '👑 저축의 달인';
    else if (level >= 5) title = '🌳 프로 절약러';
    else if (level >= 3) title = '🌿 견습 짠돌이';

    return Container(
      padding: const EdgeInsets.all(24),
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
          Row(
            children: [
              Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.micro.copyWith(color: AppColors.primaryLight, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(name, style: AppTextStyles.greetingTitle.copyWith(color: Colors.white)),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text('Lv.$level', style: AppTextStyles.micro.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text('함께 기록한 지 ${userData['createdAt'] != null ? DateTime.now().difference((userData['createdAt'] as Timestamp).toDate()).inDays + 1 : 45}일째!',
                        style: AppTextStyles.captionNormal.copyWith(color: Colors.white70)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // 경험치 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('EXP', style: AppTextStyles.micro.copyWith(color: Colors.white70, fontWeight: FontWeight.bold)),
                  Text('$xp / $requiredXp', style: AppTextStyles.micro.copyWith(color: Colors.white70)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.15),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCollection(int level) {
    // 뱃지 데이터
    final allBadges = [
      {'level': 1, 'icon': '👶', 'name': '시작'},
      {'level': 3, 'icon': '🌱', 'name': '씨앗'},
      {'level': 5, 'icon': '🌿', 'name': '새싹'},
      {'level': 10, 'icon': '🌳', 'name': '나무'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('나의 뱃지 컬렉션', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: allBadges.map((b) {
              final isUnlocked = level >= (b['level'] as int);
              return Column(
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: isUnlocked ? AppColors.tagBg : AppColors.surface,
                      shape: BoxShape.circle,
                      border: isUnlocked ? Border.all(color: AppColors.primaryLight, width: 2) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      isUnlocked ? (b['icon'] as String) : '🔒',
                      style: TextStyle(fontSize: 24, color: isUnlocked ? null : AppColors.textHint),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    b['name'] as String,
                    style: AppTextStyles.micro.copyWith(
                      color: isUnlocked ? AppColors.textPrimary : AppColors.textHint,
                      fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _formatExpense(int amount) {
    if (amount == 0) return '0원';
    if (amount >= 10000) {
      return '${(amount / 10000).toStringAsFixed(0)}만원';
    } else {
      return '${amount}원';
    }
  }

  Widget _buildStatsRow(String uid) {
    return StreamBuilder<Budget?>(
      stream: BudgetService.budgetStream(uid),
      builder: (context, budgetSnap) {
        final totalSpent = budgetSnap.data?.totalSpent ?? 0;
        
        return StreamBuilder<List<Challenge>>(
          stream: ChallengeService.allChallengesStream(uid),
          builder: (context, challengeSnap) {
            final challenges = challengeSnap.data ?? [];
            final goalAchievedCount = challenges.where((c) => !c.isActive).length;
            
            return StreamBuilder<List<Expense>>(
              stream: BudgetService.expenseStream(uid),
              builder: (context, expenseSnap) {
                final expenses = expenseSnap.data ?? [];
                
                // 절약일수 계산 (무지출 일수): 이번달 경과 일수 - 지출 발생 일수
                final now = DateTime.now();
                final daysPassed = now.day;
                final spentDays = expenses.map((e) => e.spentAt.toDate().day).toSet().length;
                final savingDays = daysPassed - spentDays;
                
                return Row(
                  children: [
                    _StatBox(label: '이번달 지출', value: _formatExpense(totalSpent), icon: Icons.account_balance_wallet, color: AppColors.primary),
                    const SizedBox(width: 12),
                    _StatBox(label: '목표 달성', value: '$goalAchievedCount회', icon: Icons.flag_rounded, color: AppColors.stateCaution),
                    const SizedBox(width: 12),
                    _StatBox(label: '절약 일수', value: '$savingDays일', icon: Icons.savings, color: AppColors.stateSafe),
                  ],
                );
              }
            );
          }
        );
      }
    );
  }

  Widget _buildGoalsCard(BuildContext context, String uid, Map<String, dynamic> userData) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('진행 중인 챌린지', style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary)),
              GestureDetector(
                onTap: () async {
                  // 고정 지출 총합 계산
                  int totalFixed = 0;
                  try {
                    final snap = await FirebaseFirestore.instance
                        .collection(CollectionKeys.users)
                        .doc(uid)
                        .collection(CollectionKeys.fixedExpenses)
                        .get();
                    totalFixed = snap.docs.fold<int>(
                        0, (acc, doc) => acc + (doc.data()['amount'] as num).toInt());
                  } catch (_) {}

                  if (!context.mounted) return;
                  context.push('/onboarding/challenge-setup', extra: {
                    'characterType': userData['characterType'] as String? ?? 'ant_shopping',
                    'monthlyIncome': userData['monthlyIncome'] as int? ?? 0,
                    'fixedExpenses': totalFixed,
                    'isFromOnboarding': false,
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text('+ 추가', style: AppTextStyles.captionNormal.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<List<Challenge>>(
            stream: ChallengeService.activeChallengesStream(uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final challenges = snapshot.data ?? [];
              if (challenges.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('현재 진행 중인 목표가 없습니다.', style: TextStyle(color: AppColors.textHint, fontSize: 14)),
                );
              }
              return Column(
                children: challenges.map((c) => _buildChallengeItem(context, uid, c)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeItem(BuildContext context, String uid, Challenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgPage,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(challenge.emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              challenge.title,
              style: AppTextStyles.bodyBold.copyWith(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.check_circle_outline, color: AppColors.primary),
            tooltip: '완료하기',
            onPressed: () async {
              // 진행 중 표시를 위해 스낵바 먼저 띄우기
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('목표 달성 처리 중...'), duration: Duration(milliseconds: 500)));
              
              final newLevel = await ChallengeService.completeChallenge(uid: uid, challengeId: challenge.id);
              
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              
              if (newLevel != null) {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('🎉', style: TextStyle(fontSize: 60)),
                          const SizedBox(height: 16),
                          Text(
                            '레벨 업!',
                            style: AppTextStyles.greetingTitle.copyWith(color: AppColors.primary, fontSize: 24),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '축하합니다!\n새로운 칭호와 뱃지가 해금되었을지도 몰라요!',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body,
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              'Lv.$newLevel',
                              style: AppTextStyles.heroAmount.copyWith(color: AppColors.primary, fontSize: 32),
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('확인', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('목표 달성! +10 XP 획득 ✨'), duration: Duration(seconds: 2))
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.textHint),
            tooltip: '삭제하기',
            onPressed: () {
              ChallengeService.deleteChallenge(uid: uid, challengeId: challenge.id);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChartsCard(String uid) {
    return StreamBuilder<List<Expense>>(
      stream: BudgetService.expenseStream(uid),
      builder: (context, expenseSnap) {
        final expenses = expenseSnap.data ?? [];
        
        // 카테고리 비율 계산
        int totalExpenses = 0;
        Map<String, int> categorySums = {};
        for (var e in expenses) {
          totalExpenses += e.amount;
          categorySums[e.category] = (categorySums[e.category] ?? 0) + e.amount;
        }
        
        List<Map<String, dynamic>> categoryData = [];
        if (totalExpenses > 0) {
          categorySums.forEach((key, sum) {
            if (sum > 0) {
              categoryData.add({
                'name': CategoryKeys.label(key),
                'ratio': (sum / totalExpenses) * 100,
                'color': AppColors.categoryColors[key] ?? AppColors.textHint,
              });
            }
          });
          categoryData.sort((a, b) => (b['ratio'] as double).compareTo(a['ratio'] as double));
        } else {
          categoryData = [
             {'name': '지출 없음', 'ratio': 100.0, 'color': AppColors.surfaceMuted},
          ];
        }

        return FutureBuilder<List<double>>(
          future: _pastMonthsFuture,
          builder: (context, pastSnap) {
            final pastExpenses = pastSnap.data ?? [0.0, 0.0, 0.0, 0.0];
            
            // 월 라벨 계산
            final now = DateTime.now();
            List<String> monthLabels = [];
            for (int i = 3; i >= 0; i--) {
              final date = DateTime(now.year, now.month - i, 1);
              monthLabels.add('${date.month}월');
            }

            // 차트 최대 Y값 계산 (여유있게 설정, 최소 10만 원)
            double maxY = 100000.0; 
            for (var val in pastExpenses) {
              if (val > maxY) maxY = val * 1.2;
            }
            if (maxY == 0) maxY = 10.0;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('카테고리 비율', style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: PieChart(PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: categoryData.map((e) => PieChartSectionData(
                        color: e['color'],
                        value: e['ratio'] as double,
                        title: '${(e['ratio'] as double).toInt()}%',
                        titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                        radius: 34,
                      )).toList(),
                    )),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 4,
                    children: categoryData.map((e) => Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: e['color'], shape: BoxShape.circle)),
                        const SizedBox(width: 4),
                        Text(e['name'], style: AppTextStyles.captionNormal),
                      ]
                    )).toList(),
                  ),
                  const Divider(height: 32),
                  Text('최근 4개월 지출 추이', style: AppTextStyles.sectionHeader),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: BarChart(BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: maxY,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (v, _) => Text(monthLabels[v.toInt()], style: AppTextStyles.captionNormal),
                          ),
                        ),
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(4, (i) => BarChartGroupData(
                        x: i,
                        barRods: [BarChartRodData(
                          toY: pastExpenses[i],
                          color: i == 3 ? AppColors.primary : AppColors.tagBg,
                          width: 18,
                          borderRadius: BorderRadius.circular(6),
                        )],
                      )),
                    )),
                  ),
                ],
              ),
            );
          }
        );
      }
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatBox({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: color.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 8),
            Text(value, style: AppTextStyles.bodyBold.copyWith(fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
            const SizedBox(height: 2),
            Text(label, style: AppTextStyles.captionNormal, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
