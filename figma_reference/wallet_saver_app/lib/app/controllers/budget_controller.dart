import 'package:get/get.dart';
import '../data/models/budget_state.dart';

/// 예산 상태 컨트롤러
/// 전체 예산 / 지출 / 잔여 / BudgetState 를 반응형으로 관리
class BudgetController extends GetxController {
  // ── 설정값 ────────────────────────────────────────────────
  /// 이번 달 총 예산 (원)
  final Rx<int> monthlyBudget = 750000.obs;

  /// 이번 달 총 지출 (원, 양수로 저장)
  final Rx<int> totalSpent = 170200.obs;

  /// 남은 일수
  final Rx<int> daysRemaining = 28.obs;

  // ── 파생 계산값 (getter) ──────────────────────────────────

  /// 잔여 예산
  int get remaining => (monthlyBudget.value - totalSpent.value).clamp(0, monthlyBudget.value);

  /// 잔여 비율 (0~100)
  double get remainPct {
    if (monthlyBudget.value == 0) return 0;
    return (remaining / monthlyBudget.value * 100).clamp(0, 100);
  }

  /// 오늘 쓸 수 있는 돈
  int get dailyBudget {
    if (daysRemaining.value <= 0) return 0;
    return (remaining / daysRemaining.value).floor();
  }

  /// 현재 예산 상태
  BudgetState get budgetState => getBudgetState(remainPct);

  /// 현재 테마 데이터
  BudgetThemeData get theme => budgetThemeMap[budgetState]!;

  // ── Actions ───────────────────────────────────────────────

  /// 지출 추가 (amount: 양수로 전달)
  void addExpense(int amount) {
    totalSpent.value += amount;
  }

  /// 지출 취소/삭제
  void removeExpense(int amount) {
    totalSpent.value = (totalSpent.value - amount).clamp(0, 999999999);
  }

  /// 예산 설정 변경
  void setBudget(int newBudget) {
    monthlyBudget.value = newBudget;
  }

  /// 데모용: 직접 잔여 비율 조정 (0~100)
  void setRemainPct(double pct) {
    totalSpent.value = (monthlyBudget.value * (1 - pct / 100)).round();
  }
}
