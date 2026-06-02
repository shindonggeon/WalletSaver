import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/ai_service.dart';
import '../services/budget_service.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  Future<String>? monthlyReportFuture;
  bool _isLoading = true;
  String _reportDate = '';
  String _topCategoryInsight = '이번 달 데이터를 분석 중입니다...';
  List<Map<String, dynamic>> _categoryStats = [];
  String _charEmoji = '🦁';
  String _charName = '소리 AI';

  // 아직 실제 위험지역 알림 시스템이 없으므로 임시 데이터를 표시하거나 비워둘 수 있습니다.
  static const List<Map<String, dynamic>> nagHistory = [
    {
      'date': '04.02',
      'location': '스타필드 코엑스',
      'msg': '예산의 64%를 사용했어요. 오늘 예산 15,300원 남았습니다.',
    },
    {
      'date': '03.28',
      'location': '신세계백화점 강남점',
      'msg': '이번 달 쇼핑에 이미 98,000원 썼어요. 한 번만 참아봐요!',
    },
    {
      'date': '03.21',
      'location': '홍대 거리',
      'msg': '주말 지출 주의! 지난 주말에도 43,000원 썼었어요.',
    },
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _reportDate = '${now.year}.${now.month.toString().padLeft(2, '0')}.${now.day.toString().padLeft(2, '0')} 생성';
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. 유저 정보
      final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
      final characterType = userDoc.data()?['characterType'] as String? ?? 'lion';
      final charInfo = CharacterTypes.characterData[characterType] ?? CharacterTypes.characterData['lion']!;
      _charEmoji = charInfo['emoji'] ?? '🦁';
      _charName = charInfo['name'] ?? '소리 AI';

      // 2. 예산 데이터
      final budgetDoc = await FirebaseFirestore.instance
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.budgets)
          .doc(BudgetService.currentYearMonth())
          .get();
      final budget = budgetDoc.exists ? Budget.fromDoc(budgetDoc) : null;
      final totalBudget = budget?.totalBudget ?? 0;
      final totalSpent = budget?.totalSpent ?? 0;
      final remainingBudget = budget?.remainingBudget ?? 0;
      final budgetUsageRate = totalBudget > 0 ? totalSpent / totalBudget : 0.0;

      // 3. 지출 내역 (이번 달)
      final expensesSnap = await FirebaseFirestore.instance
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.expenses)
          .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime(now.year, now.month, 1)))
          .get();

      final expenses = expensesSnap.docs.map((d) => Expense.fromDoc(d)).toList();

      // 카테고리별 집계
      final Map<String, int> catMap = {};
      for (var e in expenses) {
        catMap[e.category] = (catMap[e.category] ?? 0) + e.amount;
      }

      // 차트용 데이터 가공
      final sortedEntries = catMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
      final totalMapSpent = catMap.values.fold(0, (s, e) => s + e);
      
      final colors = [
        const Color(0xFF7C63F5),
        const Color(0xFFF59E0B),
        const Color(0xFF92400E),
        const Color(0xFF10B981),
        const Color(0xFF3B82F6),
        const Color(0xFF9CA3AF),
      ];

      _categoryStats = [];
      int colorIndex = 0;
      for (var entry in sortedEntries) {
        final ratio = totalMapSpent > 0 ? (entry.value / totalMapSpent) * 100 : 0.0;
        _categoryStats.add({
          'name': _getCatName(entry.key),
          'ratio': double.parse(ratio.toStringAsFixed(1)),
          'color': colors[colorIndex % colors.length],
          'change': 0.0, // 더미 대비 증감
        });
        colorIndex++;
      }

      if (_categoryStats.isNotEmpty) {
        _topCategoryInsight = '이번 달 ${_categoryStats.first['name']}(${_formatWon(sortedEntries.first.value)})이 가장 많은 지출을 차지했어요.';
      } else {
        _topCategoryInsight = '이번 달 지출 내역이 아직 없습니다.';
      }

      // 4. 리포트 생성
      if (mounted) {
        setState(() {
          monthlyReportFuture = AiService().generateMonthlyReport(
            age: 20, // 나이 기본값
            totalBudget: totalBudget,
            totalSpent: totalSpent,
            remainingBudget: remainingBudget,
            budgetUsageRate: budgetUsageRate,
            categorySpending: catMap,
            monthlyGoal: '이번 달 절약하기',
            characterType: characterType,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('AI 로드 실패: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  DateTime get now => DateTime.now();

  String _getCatName(String cat) {
    switch (cat) {
      case 'shopping': return '쇼핑';
      case 'food': return '식비';
      case 'cafe': return '카페';
      case 'transport': return '교통';
      case 'living': return '생활';
      case 'leisure': return '여가';
      case 'convenience': return '편의';
      default: return '기타';
    }
  }

  String _formatWon(int value) {
    return '${value.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgPage,
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: true,
            pinned: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('소리 AI', style: AppTextStyles.pageTitle),
                Text(_reportDate, style: AppTextStyles.captionNormal),
              ],
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: DropdownButton<String>(
                  value: '4월',
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: AppColors.textHint,
                  ),
                  underline: const SizedBox(),
                  style: AppTextStyles.bodyBold.copyWith(
                    color: AppColors.primary,
                  ),
                  items: ['3월', '4월', '5월']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
          _isLoading 
            ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            : SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildChatBubble(),
                    const SizedBox(height: 24),
                    Text('소비 인사이트', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 12),
                    _buildHorizontalInsightCards(),
                    const SizedBox(height: 24),
                    Text('카테고리별 지출', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 12),
                    _buildDonutSection(),
                    const SizedBox(height: 24),
                    Text('최근 위험 지역 진입 알림', style: AppTextStyles.sectionHeader),
                    const SizedBox(height: 12),
                    ...nagHistory.map((h) => _buildNagItem(h)),
                  ]),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildChatBubble() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 캐릭터 프로필
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8)],
          ),
          alignment: Alignment.center,
          child: Text(_charEmoji, style: const TextStyle(fontSize: 28)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_charName, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (monthlyReportFuture == null)
                      Text(
                        'AI 리포트를 생성할 데이터가 부족합니다.',
                        style: AppTextStyles.body.copyWith(height: 1.5, color: AppColors.textPrimary),
                      )
                    else
                      FutureBuilder<String>(
                        future: monthlyReportFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Row(
                              children: [
                                const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                                const SizedBox(width: 12),
                                Expanded(child: Text('이번 달 소비 내역을 분석 중입니다...', style: AppTextStyles.body.copyWith(color: AppColors.textPrimary))),
                              ],
                            );
                          }
                          return Text(
                            snapshot.data ?? _topCategoryInsight,
                            style: AppTextStyles.body.copyWith(height: 1.5, color: AppColors.textPrimary),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHorizontalInsightCards() {
    const items = [
      {
        'icon': Icons.calendar_today,
        'title': '가장 많이 쓴 요일',
        'value': '토요일',
        'isWarning': false,
      },
      {
        'icon': Icons.trending_up,
        'title': '지난주 대비 지출',
        'value': '+12,300원',
        'isWarning': true,
      },
      {
        'icon': Icons.emoji_events,
        'title': '챌린지 달성률',
        'value': '1 / 3개',
        'isWarning': false,
      },
    ];

    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: (items as List<Map<String, dynamic>>).map((item) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item['icon'] as IconData,
                  color: AppColors.primary.withValues(alpha: 0.7),
                  size: 22,
                ),
                const Spacer(),
                Text(item['title'] as String, style: AppTextStyles.captionNormal),
                const SizedBox(height: 2),
                Text(
                  item['value'] as String,
                  style: AppTextStyles.bodyBold.copyWith(
                    color: (item['isWarning'] as bool)
                        ? AppColors.stateDanger
                        : AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDonutSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                PieChart(
                  PieChartData(
                    sectionsSpace: 3,
                    centerSpaceRadius: 55,
                    sections: _categoryStats.isEmpty
                      ? [PieChartSectionData(color: AppColors.bgPage, value: 100, title: '', radius: 22)]
                      : _categoryStats
                        .map(
                          (s) => PieChartSectionData(
                            color: s['color'],
                            value: s['ratio'] as double,
                            title: '',
                            radius: 22,
                          ),
                        )
                        .toList(),
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('지출', style: AppTextStyles.captionNormal),
                    Text(
                      '100%',
                      style: AppTextStyles.bodyBold.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            children: _categoryStats.map((s) => _buildCategoryRow(s)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(Map<String, dynamic> stat) {
    final change = stat['change'] as double;
    final isUp = change > 0;
    final isZero = change == 0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: stat['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              stat['name'],
              style: AppTextStyles.body.copyWith(color: AppColors.textPrimary),
            ),
          ),
          Text('${stat['ratio']}%', style: AppTextStyles.bodyBold),
          const SizedBox(width: 12),
          if (!isZero)
            Row(
              children: [
                Icon(
                  isUp ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: isUp ? AppColors.expense : AppColors.income,
                  size: 18,
                ),
                Text(
                  '${change.abs()}%',
                  style: AppTextStyles.caption.copyWith(
                    color: isUp ? AppColors.expense : AppColors.income,
                  ),
                ),
              ],
            )
          else
            Text('-', style: AppTextStyles.captionNormal),
        ],
      ),
    );
  }

  Widget _buildNagItem(Map<String, dynamic> item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.white,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
            ),
            alignment: Alignment.center,
            child: Text(_charEmoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(_charName, style: AppTextStyles.captionNormal.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 6),
                    Text(item['date'], style: AppTextStyles.micro.copyWith(color: AppColors.textHint)),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    border: Border.all(color: AppColors.stateDanger.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on, color: AppColors.stateDanger, size: 14),
                          const SizedBox(width: 4),
                          Text(item['location'], style: AppTextStyles.captionNormal.copyWith(color: AppColors.stateDanger, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(item['msg'], style: AppTextStyles.body.copyWith(height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryLight.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.auto_awesome,
            color: AppColors.primaryLight,
            size: 13,
          ),
          const SizedBox(width: 4),
          Text(
            'AI 생성 · 4월 요약',
            style: AppTextStyles.micro.copyWith(
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InsightRow({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.body.copyWith(color: Colors.white70),
          ),
        ),
      ],
    );
  }
}