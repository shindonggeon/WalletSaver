import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/expense.dart';
import '../models/budget.dart';
import '../services/budget_service.dart';
import '../constants/app_constants.dart';

class LedgerScreen extends StatefulWidget {
  const LedgerScreen({super.key});

  @override
  State<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends State<LedgerScreen> {
  String selectedMonth = '5월';
  static const List<String> categories = ['전체', '식비', '카페', '쇼핑', '교통', '생활'];
  
  String selectedCategory = '전체';
  int selectedTab = 0; // 0=전체, 1=지출, 2=수입
  
  // 지출 추가 폼 컨트롤러
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _showAddExpenseBottomSheet(BuildContext context, String uid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgPage,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20, right: 20, top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('지출 추가', style: AppTextStyles.pageTitle),
              const SizedBox(height: 16),
              TextField(
                controller: _merchantController,
                decoration: InputDecoration(
                  labelText: '가맹점명 (예: 스타벅스)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: '금액 (원)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: () async {
                    final merchant = _merchantController.text.trim();
                    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
                    if (merchant.isEmpty || amount <= 0) return;

                    final expense = Expense(
                      id: '',
                      amount: amount,
                      category: BudgetService.classifyCategory(merchant),
                      merchant: merchant,
                      isAuto: false,
                      spentAt: Timestamp.now(),
                    );

                    // 실제 수입/고정지출 값 조회
                    int income = 2500000;
                    int fixedExp = 500000;
                    try {
                      final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
                      income = userDoc.data()?['monthlyIncome'] as int? ?? 0;
                      final fixedSnap = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).collection(CollectionKeys.fixedExpenses).get();
                      fixedExp = fixedSnap.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['amount'] as num).toInt());
                    } catch (_) {}

                    await BudgetService.addExpense(
                      uid: uid,
                      expense: expense,
                      monthlyIncome: income,
                      fixedExpenses: fixedExp,
                    );

                    _merchantController.clear();
                    _amountController.clear();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: Text('추가하기', style: AppTextStyles.button),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
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
      body: StreamBuilder<Budget?>(
        stream: BudgetService.budgetStream(uid),
        builder: (context, budgetSnap) {
          final budget = budgetSnap.data;
          
          return StreamBuilder<List<Expense>>(
            stream: BudgetService.expenseStream(uid),
            builder: (context, expenseSnap) {
              var expenses = expenseSnap.data ?? [];
              
              // 필터링 적용
              if (selectedCategory != '전체') {
                expenses = expenses.where((e) => CategoryKeys.label(e.category) == selectedCategory).toList();
              }

              return CustomScrollView(
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
                          _buildSummaryCard(budget),
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
                        (context, index) => _buildLedgerItem(expenses[index], uid),
                        childCount: expenses.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              );
            }
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseBottomSheet(context, uid),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryCard(Budget? budget) {
    final totalIncome = budget?.totalBudget ?? 2500000;
    final totalExpense = budget?.totalSpent ?? 0;
    final netIncome = totalIncome - totalExpense;

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

  Widget _buildLedgerItem(Expense item, String uid) {
    final catColor = AppColors.categoryColors[item.category] ?? AppColors.textHint;
    final catLabel = CategoryKeys.label(item.category);
    final date = item.spentAt.toDate();
    final dateStr = '${date.month.toString().padLeft(2,'0')}.${date.day.toString().padLeft(2,'0')}';

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade400,
          borderRadius: BorderRadius.circular(16),
        ),
        margin: const EdgeInsets.only(bottom: 14),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) async {
        int income = 2500000;
        int fixedExp = 500000;
        try {
          final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
          income = userDoc.data()?['monthlyIncome'] as int? ?? 0;
          final fixedSnap = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).collection(CollectionKeys.fixedExpenses).get();
          fixedExp = fixedSnap.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['amount'] as num).toInt());
        } catch (_) {}

        BudgetService.deleteExpense(
          uid: uid, expenseId: item.id, monthlyIncome: income, fixedExpenses: fixedExp
        );
      },
      child: Padding(
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
                child: Text(catLabel.substring(0,1), style: TextStyle(fontSize: 22, color: catColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.merchant, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
                    Text('$catLabel · $dateStr', style: AppTextStyles.captionNormal),
                  ],
                ),
              ),
              Text(
                '-${formatNumber(item.amount)}원',
                style: AppTextStyles.bodyBold.copyWith(
                  color: AppColors.expense,
                ),
              ),
            ],
          ),
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
