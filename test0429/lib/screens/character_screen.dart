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

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  // ── Dummy Data ──────────────────────────────────────────
  static const int recordDays = 45;
  static const int monthlyExpense = 340000;
  static const int goalAchievedCount = 3;
  static const int savingDays = 12;

  static const List<Map<String, dynamic>> categoryData = [
    {'name': '식비', 'ratio': 40.0, 'color': Color(0xFFF59E0B)},
    {'name': '카페', 'ratio': 20.0, 'color': Color(0xFF92400E)},
    {'name': '교통', 'ratio': 15.0, 'color': Color(0xFF3B82F6)},
    {'name': '기타', 'ratio': 25.0, 'color': Color(0xFF9CA3AF)},
  ];

  static const List<double> monthlyBars = [45.0, 52.0, 38.0, 34.0];
  static const List<String> monthLabels = ['1월', '2월', '3월', '4월'];
  // ────────────────────────────────────────────────────────

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
          final charInfo = CharacterTypes.characterData[characterType] ?? CharacterTypes.characterData['ant_shopping']!;
          final charEmoji = charInfo['emoji'] ?? '🐜';
          final charName = charInfo['name'] ?? '알뜰한 개미';

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar(
                backgroundColor: AppColors.bgPage,
                pinned: true,
                floating: true,
                title: Text('내 캐릭터', style: AppTextStyles.pageTitle),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildProfileCard(charEmoji, charName, charLevel),
                    const SizedBox(height: 16),
                    _buildStatsRow(),
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
                    _buildChartsCard(),
                  ]),
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  Widget _buildProfileCard(String emoji, String name, int level) {
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
      child: Row(
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
                Text('함께 기록한 지 $recordDays일째!',
                    style: AppTextStyles.captionNormal.copyWith(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Row(
      children: [
        _StatBox(label: '이번달 지출', value: '${(monthlyExpense / 10000).toStringAsFixed(0)}만원', icon: Icons.account_balance_wallet, color: AppColors.primary),
        const SizedBox(width: 12),
        _StatBox(label: '목표 달성', value: '$goalAchievedCount회', icon: Icons.flag_rounded, color: AppColors.stateCaution),
        const SizedBox(width: 12),
        _StatBox(label: '절약 일수', value: '$savingDays일', icon: Icons.savings, color: AppColors.stateSafe),
      ],
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
              
              await ChallengeService.completeChallenge(uid: uid, challengeId: challenge.id);
              
              if (!context.mounted) return;
              
              // 최신 레벨 가져오기
              final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
              final newLevel = userDoc.data()?['level'] as int? ?? 1;
              
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              
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
                          '축하합니다!\n목표를 달성하여 캐릭터가 성장했습니다.',
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

  Widget _buildChartsCard() {
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
                title: '${e['ratio'].toInt()}%',
                titleStyle: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                radius: 34,
              )).toList(),
            )),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: categoryData.map((e) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(children: [
                Container(width: 8, height: 8, decoration: BoxDecoration(color: e['color'], shape: BoxShape.circle)),
                const SizedBox(width: 4),
                Text(e['name'], style: AppTextStyles.captionNormal),
              ]),
            )).toList(),
          ),
          const Divider(height: 32),
          Text('최근 4개월 지출 추이', style: AppTextStyles.sectionHeader),
          const SizedBox(height: 12),
          SizedBox(
            height: 140,
            child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: 60,
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
                  toY: monthlyBars[i],
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
