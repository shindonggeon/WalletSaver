import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/app_theme.dart';

class CharacterScreen extends StatelessWidget {
  const CharacterScreen({super.key});

  // ── Dummy Data ──────────────────────────────────────────
  static const String charEmoji = '🐿️';
  static const String charName = '알뜰한 다람쥐';
  static const int charLevel = 12;
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
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
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
                _buildProfileCard(),
                const SizedBox(height: 16),
                _buildStatsRow(),
                const SizedBox(height: 24),
                Text('지출 리포트', style: AppTextStyles.sectionHeader),
                const SizedBox(height: 12),
                _buildChartsCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
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
            child: Text(charEmoji, style: const TextStyle(fontSize: 40)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(charName, style: AppTextStyles.greetingTitle.copyWith(color: Colors.white)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('Lv.$charLevel', style: AppTextStyles.micro.copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
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
