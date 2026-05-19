import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../services/ai_service.dart';
import '../theme/app_theme.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  late final Future<String> monthlyReportFuture;

  // ── Dummy Data ──────────────────────────────────────────
  static const String reportDate = '2025.04.29 생성';
  static const String topCategoryInsight = '이번 달 쇼핑(134,000원)이 가장 많은 지출을 차지했어요.';
  static const String changeInsight = '지난달 대비 카페 지출이 23% 증가했습니다.';
  static const String habitInsight =
      '저번주 이 시간에도 스타벅스에 5,500원 쓰셨는데\n혹시 습관이 된 건 아닌가요?';

  static const List<Map<String, dynamic>> categoryStats = [
    {'name': '쇼핑', 'ratio': 28.0, 'color': Color(0xFF7C63F5), 'change': 12.0},
    {'name': '식비', 'ratio': 27.0, 'color': Color(0xFFF59E0B), 'change': -2.5},
    {'name': '카페', 'ratio': 19.0, 'color': Color(0xFF92400E), 'change': 23.0},
    {'name': '생활', 'ratio': 11.0, 'color': Color(0xFF10B981), 'change': -5.2},
    {'name': '교통', 'ratio': 9.0, 'color': Color(0xFF3B82F6), 'change': 0.0},
    {'name': '기타', 'ratio': 6.0, 'color': Color(0xFF9CA3AF), 'change': -1.0},
  ];

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
  // ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();

    monthlyReportFuture = AiService().generateMonthlyReport(
      age: 23,
      totalBudget: 600000,
      totalSpent: 520000,
      remainingBudget: 80000,
      budgetUsageRate: 0.867,
      categorySpending: {
        'shopping': 134000,
        'food': 129000,
        'cafe': 91000,
        'living': 53000,
        'transport': 43000,
        'etc': 29000,
      },
      monthlyGoal: '이번 달 쇼핑 줄이기',
      characterType: 'lion',
    );
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
                Text(reportDate, style: AppTextStyles.captionNormal),
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
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildDarkInsightCard(),
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

  Widget _buildDarkInsightCard() {
    return Container(
      padding: const EdgeInsets.all(24),
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
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _AiBadge(),
          const SizedBox(height: 16),
          FutureBuilder<String>(
            future: monthlyReportFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Text(
                  'AI가 이번 달 소비 리포트를 생성하는 중입니다...',
                  style: AppTextStyles.heroAmount.copyWith(
                    fontSize: 18,
                    letterSpacing: 0,
                  ),
                );
              }

              return Text(
                snapshot.data ?? topCategoryInsight,
                style: AppTextStyles.heroAmount.copyWith(
                  fontSize: 18,
                  letterSpacing: 0,
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withValues(alpha: 0.15)),
          const SizedBox(height: 12),
          _InsightRow(
            icon: Icons.show_chart,
            color: AppColors.stateDanger,
            text: changeInsight,
          ),
          const SizedBox(height: 10),
          _InsightRow(
            icon: Icons.psychology,
            color: AppColors.stateCaution,
            text: habitInsight,
          ),
        ],
      ),
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
                    sections: categoryStats
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
            children: categoryStats.map((s) => _buildCategoryRow(s)).toList(),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.stateDanger.withValues(alpha: 0.25),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.stateDanger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on,
                color: AppColors.stateDanger,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item['location'],
                        style: AppTextStyles.bodyBold.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(item['date'], style: AppTextStyles.captionNormal),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(item['msg'], style: AppTextStyles.body),
                ],
              ),
            ),
          ],
        ),
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