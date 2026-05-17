import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'firebase_options.dart';
import 'models/expense.dart';
import 'models/budget.dart';
import 'models/user.dart';
import 'services/budget_service.dart';
import 'constants/app_constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const SoriApp());
}

class SoriApp extends StatelessWidget {
  const SoriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '소리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6B5CE7)),
        useMaterial3: true,
      ),
      home: const _AuthGate(),
    );
  }
}

// ── 인증 상태 감지 ────────────────────────────────────────────────────────────

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return HomePage(uid: snapshot.data!.uid);
        }
        return const _SignInPage();
      },
    );
  }
}

class _SignInPage extends StatelessWidget {
  const _SignInPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('소리', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('성향 분석 기반 맞춤형 지출 관리', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () async {
                await FirebaseAuth.instance.signInAnonymously();
              },
              child: const Text('시작하기'),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 홈 화면 ───────────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  final String uid;
  const HomePage({super.key, required this.uid});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _merchantController = TextEditingController();
  final _amountController = TextEditingController();

  // ── Dummy Data: 파트 2 완료 후 Firestore에서 읽어온 AppUser 값으로 교체 ──
  static const int _monthlyIncome = 2_000_000;
  static const int _fixedExpenses = 500_000;
  // ──────────────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _addExpense() async {
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

    await BudgetService.addExpense(
      uid: widget.uid,
      expense: expense,
      monthlyIncome: _monthlyIncome,
      fixedExpenses: _fixedExpenses,
    );

    _merchantController.clear();
    _amountController.clear();
  }

  Future<void> _deleteExpense(String expenseId) async {
    await BudgetService.deleteExpense(
      uid: widget.uid,
      expenseId: expenseId,
      monthlyIncome: _monthlyIncome,
      fixedExpenses: _fixedExpenses,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('소리 가계부'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: StreamBuilder<Budget?>(
        stream: BudgetService.budgetStream(widget.uid),
        builder: (context, budgetSnap) {
          final budget = budgetSnap.data;
          return StreamBuilder<List<Expense>>(
            stream: BudgetService.expenseStream(widget.uid),
            builder: (context, expenseSnap) {
              final expenses = expenseSnap.data ?? [];
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _BudgetCard(budget: budget),
                    const SizedBox(height: 16),
                    if (expenses.isNotEmpty) _CategoryChart(expenses: expenses),
                    const SizedBox(height: 16),
                    _AddExpenseForm(
                      merchantController: _merchantController,
                      amountController: _amountController,
                      onAdd: _addExpense,
                    ),
                    const SizedBox(height: 16),
                    _ExpenseList(
                      expenses: expenses,
                      onDelete: _deleteExpense,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── 예산 카드 ─────────────────────────────────────────────────────────────────

class _BudgetCard extends StatelessWidget {
  final Budget? budget;
  const _BudgetCard({this.budget});

  Color _themeColor(double usageRate) {
    if (usageRate >= 100) return const Color(0xFF501313);
    if (usageRate >= 80) return const Color(0xFFA32D2D);
    if (usageRate >= 50) return const Color(0xFFBA7517);
    return const Color(0xFF6B5CE7);
  }

  @override
  Widget build(BuildContext context) {
    final usageRate = budget?.budgetUsageRate ?? 0;
    final color = _themeColor(usageRate);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('오늘 쓸 수 있는 돈', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            budget != null
                ? '${_format(budget!.todayBudget)}원'
                : '계산 중...',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _BudgetStat(label: '총 예산', value: budget != null ? _format(budget!.totalBudget) : '-'),
              _BudgetStat(label: '지출', value: budget != null ? _format(budget!.totalSpent) : '-'),
              _BudgetStat(label: '잔여', value: budget != null ? _format(budget!.remainingBudget) : '-'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: (usageRate / 100).clamp(0.0, 1.0),
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation(Colors.white),
            minHeight: 6,
            borderRadius: BorderRadius.circular(3),
          ),
          const SizedBox(height: 4),
          Text(
            '예산 사용률 ${usageRate.toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _format(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _BudgetStat extends StatelessWidget {
  final String label;
  final String value;
  const _BudgetStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        Text('$value원', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

// ── 카테고리 차트 ─────────────────────────────────────────────────────────────

class _CategoryChart extends StatelessWidget {
  final List<Expense> expenses;
  const _CategoryChart({required this.expenses});

  static const _colors = {
    CategoryKeys.food: Colors.red,
    CategoryKeys.cafe: Colors.orange,
    CategoryKeys.shopping: Colors.purple,
    CategoryKeys.transport: Colors.blue,
    CategoryKeys.living: Colors.teal,
    CategoryKeys.etc: Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final e in expenses) {
      totals[e.category] = (totals[e.category] ?? 0) + e.amount;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('카테고리별 지출', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        SizedBox(
          height: 180,
          child: PieChart(PieChartData(
            sections: totals.entries.map((e) => PieChartSectionData(
              value: e.value.toDouble(),
              title: CategoryKeys.label(e.key),
              color: _colors[e.key] ?? Colors.grey,
              radius: 70,
              titleStyle: const TextStyle(fontSize: 12, color: Colors.white),
            )).toList(),
          )),
        ),
      ],
    );
  }
}

// ── 지출 입력 폼 ──────────────────────────────────────────────────────────────

class _AddExpenseForm extends StatelessWidget {
  final TextEditingController merchantController;
  final TextEditingController amountController;
  final VoidCallback onAdd;

  const _AddExpenseForm({
    required this.merchantController,
    required this.amountController,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('지출 추가', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: merchantController,
          decoration: const InputDecoration(
            labelText: '가맹점명 (예: 스타벅스)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: amountController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: '금액 (원)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: onAdd,
            child: const Text('추가하기'),
          ),
        ),
      ],
    );
  }
}

// ── 지출 목록 ─────────────────────────────────────────────────────────────────

class _ExpenseList extends StatelessWidget {
  final List<Expense> expenses;
  final Future<void> Function(String) onDelete;

  const _ExpenseList({required this.expenses, required this.onDelete});

  static const _categoryColors = {
    CategoryKeys.food: Colors.red,
    CategoryKeys.cafe: Colors.orange,
    CategoryKeys.shopping: Colors.purple,
    CategoryKeys.transport: Colors.blue,
    CategoryKeys.living: Colors.teal,
    CategoryKeys.etc: Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    if (expenses.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('이번 달 지출 내역이 없습니다.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('이번 달 지출 내역', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ...expenses.map((e) => Card(
          margin: const EdgeInsets.only(bottom: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: (_categoryColors[e.category] ?? Colors.grey) as Color,
              child: Text(
                CategoryKeys.label(e.category).substring(0, 1),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            title: Text(e.merchant),
            subtitle: Text(
              '${CategoryKeys.label(e.category)} · ${_formatDate(e.spentAt)}',
              style: const TextStyle(fontSize: 12),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '-${_format(e.amount)}원',
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: () => onDelete(e.id),
                ),
              ],
            ),
          ),
        )),
      ],
    );
  }

  String _format(int n) =>
      n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  String _formatDate(Timestamp ts) {
    final d = ts.toDate();
    return '${d.month}/${d.day}';
  }
}
