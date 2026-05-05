import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  // ── Dummy Data ──────────────────────────────────────────
  String selectedMonth = '4월';
  static const int totalIncome = 2500000;
  static const int totalExpense = 1450000;
  static const int netIncome = 1050000;
  static const List<String> categories = ['전체', '식비', '카페', '쇼핑', '교통', '생활'];
  static const List<Map<String, dynamic>> ledgerList = [
    {'date': '04.29', 'title': '스타벅스', 'category': '카페', 'amount': -5500, 'emoji': '☕'},
    {'date': '04.29', 'title': 'CU 편의점', 'category': '식비', 'amount': -4200, 'emoji': '🏪'},
    {'date': '04.28', 'title': '월급', 'category': '수입', 'amount': 2500000, 'emoji': '💰'},
    {'date': '04.27', 'title': '배달의민족', 'category': '식비', 'amount': -24000, 'emoji': '🛵'},
    {'date': '04.26', 'title': '지하철 정기권', 'category': '교통', 'amount': -55000, 'emoji': '🚇'},
  ];
  // ────────────────────────────────────────────────────────

  String selectedCategory = '전체';
  int selectedTab = 0; // 0=전체, 1=지출, 2=수입

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
            expandedHeight: 60,
            title: Row(
              children: [
                Text('가계부', style: AppTextStyles.pageTitle),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: selectedMonth,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textHint, size: 20),
                  underline: const SizedBox(),
                  style: AppTextStyles.bodyBold.copyWith(color: AppColors.primary),
                  items: ['3월', '4월', '5월'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => setState(() => selectedMonth = val!),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Column(
                children: [
                  _buildSummaryCard(),
                  const SizedBox(height: 16),
                  _buildTabRow(),
                  const SizedBox(height: 12),
                  _buildCategoryChips(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildLedgerItem(ledgerList[index]),
                childCount: ledgerList.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.gradFrom, AppColors.gradTo],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryItem(label: '수입', amount: totalIncome, color: AppColors.income),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _SummaryItem(label: '지출', amount: totalExpense, color: const Color(0xFFFF8A8A)),
          Container(width: 1, height: 40, color: Colors.white.withValues(alpha: 0.2)),
          _SummaryItem(label: '순이익', amount: netIncome, color: Colors.white),
        ],
      ),
    );
  }

  Widget _buildTabRow() {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: AppColors.tagBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: ['전체', '지출', '수입'].asMap().entries.map((e) {
          final isSelected = selectedTab == e.key;
          return Expanded(
            child: GestureDetector(
              onTap: () => setState(() => selectedTab = e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isSelected
                      ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  e.value,
                  style: AppTextStyles.caption.copyWith(
                    color: isSelected ? AppColors.primary : AppColors.textHint,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: categories.map((cat) {
          final isSelected = selectedCategory == cat;
          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Text(
                cat,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLedgerItem(Map<String, dynamic> item) {
    final isIncome = (item['amount'] as int) > 0;
    final catColor = AppColors.categoryColors[item['category']] ?? AppColors.textHint;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 44, height: 44,
              decoration: BoxDecoration(
                color: catColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(item['emoji'], style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'], style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
                  Text('${item['category']} · ${item['date']}', style: AppTextStyles.captionNormal),
                ],
              ),
            ),
            Text(
              '${isIncome ? '+' : '-'}${formatNumber((item['amount'] as int).abs())}원',
              style: AppTextStyles.bodyBold.copyWith(
                color: isIncome ? AppColors.income : AppColors.expense,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int amount;
  final Color color;
  const _SummaryItem({required this.label, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.micro.copyWith(color: Colors.white70)),
        const SizedBox(height: 4),
        Text(
          '${(amount / 10000).toStringAsFixed(0)}만',
          style: AppTextStyles.cardAmount.copyWith(color: color, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }
}
