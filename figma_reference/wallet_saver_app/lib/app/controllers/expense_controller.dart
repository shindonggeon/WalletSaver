import 'package:get/get.dart';
import '../data/models/expense_model.dart';
import 'budget_controller.dart';

/// 지출 목록 컨트롤러
/// CRUD 및 카테고리별 집계를 담당
class ExpenseController extends GetxController {
  final BudgetController _budgetCtrl = Get.find<BudgetController>();

  /// 지출/수입 전체 목록
  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // 더미 데이터로 초기화
    expenses.assignAll(dummyExpenses);
  }

  // ── 필터링 ────────────────────────────────────────────────

  List<ExpenseModel> get expensesOnly =>
      expenses.where((e) => !e.isIncome).toList();

  List<ExpenseModel> get incomeOnly =>
      expenses.where((e) => e.isIncome).toList();

  /// 최근 N건 지출만 반환
  List<ExpenseModel> recentExpenses({int count = 5}) =>
      expensesOnly.take(count).toList();

  // ── 집계 ──────────────────────────────────────────────────

  int get totalExpense =>
      expensesOnly.fold(0, (sum, e) => sum + e.absAmount);

  int get totalIncome =>
      incomeOnly.fold(0, (sum, e) => sum + e.absAmount);

  int get netAmount => totalIncome - totalExpense;

  /// 카테고리별 지출 집계 Map<카테고리, 금액>
  Map<String, int> get categoryBreakdown {
    final Map<String, int> result = {};
    for (final e in expensesOnly) {
      result[e.category] = (result[e.category] ?? 0) + e.absAmount;
    }
    return result;
  }

  /// 날짜별 그룹화 Map<dateKey, List<ExpenseModel>>
  Map<String, List<ExpenseModel>> get groupedByDate {
    final Map<String, List<ExpenseModel>> result = {};
    for (final e in expenses) {
      result.putIfAbsent(e.dateKey, () => []).add(e);
    }
    return result;
  }

  // ── CRUD ──────────────────────────────────────────────────

  void addExpense(ExpenseModel expense) {
    expenses.insert(0, expense);
    if (!expense.isIncome) {
      _budgetCtrl.addExpense(expense.absAmount);
    }
  }

  void removeExpense(String id) {
    final target = expenses.firstWhereOrNull((e) => e.id == id);
    if (target != null) {
      expenses.removeWhere((e) => e.id == id);
      if (!target.isIncome) {
        _budgetCtrl.removeExpense(target.absAmount);
      }
    }
  }

  /// 카테고리 아이콘 매핑
  static String iconForCategory(String category) {
    const icons = {
      '식비': '🍱',
      '카페': '☕',
      '쇼핑': '🛍️',
      '교통': '🚇',
      '생활': '🏪',
      '뷰티': '💄',
      '구독': '🎬',
      '수입': '💰',
      '기타': '💸',
    };
    return icons[category] ?? '💳';
  }
}
