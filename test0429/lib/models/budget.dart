import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

// Firestore 경로: users/{uid}/budgets/{YYYY-MM}
// ⚠️ 필드명 임의 변경 금지 — 전 파트 공통 사용 (BudgetKeys 참조)
class Budget {
  final int totalBudget;      // monthlyIncome − 고정지출 합계
  final int totalSpent;       // 이번 달 누적 지출 (실시간 갱신)
  final int remainingBudget;  // totalBudget − totalSpent
  final int todayBudget;      // remainingBudget ÷ 남은 일수
  final Timestamp updatedAt;  // 마지막 갱신 시각

  const Budget({
    required this.totalBudget,
    required this.totalSpent,
    required this.remainingBudget,
    required this.todayBudget,
    required this.updatedAt,
  });

  // budgetUsageRate = totalSpent ÷ totalBudget × 100  (UI 테마 변경 기준값 %)
  double get budgetUsageRate =>
      totalBudget > 0 ? (totalSpent / totalBudget * 100) : 0.0;

  // BudgetState.fromRate()에 전달할 상태 코드
  String get state => BudgetState.fromRate(budgetUsageRate);

  factory Budget.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Budget(
      totalBudget: (d[BudgetKeys.totalBudget] as num).toInt(),
      totalSpent: (d[BudgetKeys.totalSpent] as num).toInt(),
      remainingBudget: (d[BudgetKeys.remainingBudget] as num).toInt(),
      todayBudget: (d[BudgetKeys.todayBudget] as num).toInt(),
      updatedAt: d['updatedAt'] as Timestamp,
    );
  }

  /// 오늘 쓸 수 있는 돈 계산 로직 (남은 돈 / 남은 일 수)
  static Budget calculate({
    required int monthlyIncome,
    required int fixedExpenses,
    required int totalSpentBeforeToday,
    required int spentToday,
    required int daysLeftInMonth,
  }) {
    final totalBudget = monthlyIncome - fixedExpenses;
    final totalSpent = totalSpentBeforeToday + spentToday;
    final remainingBudget = totalBudget - totalSpent;
    
    // 사용자가 요청한 단순 남은 돈 / 남은 일 수 계산
    final todayBudget = daysLeftInMonth > 0 
        ? (remainingBudget / daysLeftInMonth).floor() 
        : 0;

    return Budget(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      remainingBudget: remainingBudget,
      todayBudget: todayBudget,
      updatedAt: Timestamp.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    BudgetKeys.totalBudget: totalBudget,
    BudgetKeys.totalSpent: totalSpent,
    BudgetKeys.remainingBudget: remainingBudget,
    BudgetKeys.todayBudget: todayBudget,
    'updatedAt': updatedAt,
  };
}
