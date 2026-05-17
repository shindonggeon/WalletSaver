// ════════════════════════════════════════════════════════════════════
// lib/constants/app_constants.dart
//
// 소리 (Sori) 앱 공통 상수 파일
//
// ⚠️  주의사항
//      - 이 파일의 값을 직접 수정하면 전 파트에 영향을 줍니다.
//      - 수정 전 반드시 팀장(신동건)과 협의해주세요.
//      - 값은 반드시 소문자 영어로 작성해주세요.
//
// ✅  사용법
//      import '../constants/app_constants.dart';
//
//      category: CategoryKeys.food           // ✅ 올바른 사용
//      category: 'food'                      // ❌ 하드코딩 금지
//
// 📌  파트별 담당 구역
//      CollectionKeys   → 파트 2 (송종민) 확정 후 수정
//      BudgetKeys       → 파트 2 (송종민) 확정 후 수정
//      CategoryKeys     → 파트 2 (송종민) 확정 후 수정
//      CharacterTypes   → 파트 3 (안준용) 확정 후 추가
//      NaggingIntensity → 파트 3 (안준용) 확정 후 추가
//      BudgetState      → 파트 5 (신동건) 관리
//      DangerZoneCategories → 파트 1 (김동원) 확정 후 추가
//      DateFormats      → 공통
// ════════════════════════════════════════════════════════════════════

// ── 1. Firestore 컬렉션명 ────────────────────────────────────────
class CollectionKeys {
  CollectionKeys._();

  static const String users         = 'users';
  static const String expenses      = 'expenses';
  static const String budgets       = 'budgets';
  static const String fixedExpenses = 'fixedExpenses';
  static const String challenges    = 'challenges';
  static const String dangerZones   = 'dangerZones';
  static const String aiFeedbacks   = 'aiFeedbacks'; // 잔소리 히스토리 · 월간 리포트 저장
}

// ── 2. Firestore 필드명 (예산 관련) ─────────────────────────────
class BudgetKeys {
  BudgetKeys._();

  static const String totalBudget     = 'totalBudget';
  static const String totalSpent      = 'totalSpent';
  static const String remainingBudget = 'remainingBudget';
  static const String todayBudget     = 'todayBudget';
  static const String budgetUsageRate = 'budgetUsageRate';
}

// ── 3. 지출 카테고리 코드 ────────────────────────────────────────
// ⚠️ AI 파트(최정호) 요청으로 leisure / self_satisfaction / convenience 추가 (2026-05-17)
class CategoryKeys {
  CategoryKeys._();

  static const String food              = 'food';
  static const String cafe              = 'cafe';
  static const String shopping          = 'shopping';
  static const String transport         = 'transport';
  static const String living            = 'living';
  static const String leisure           = 'leisure';           // 여가
  static const String selfSatisfaction  = 'self_satisfaction'; // 자기만족
  static const String convenience       = 'convenience';       // 편의점
  static const String etc              = 'etc';

  static const List<String> all = [
    food, cafe, shopping, transport, living,
    leisure, selfSatisfaction, convenience, etc,
  ];

  static String label(String key) {
    const map = {
      food:             '식비',
      cafe:             '카페',
      shopping:         '쇼핑',
      transport:        '교통',
      living:           '생활',
      leisure:          '여가',
      selfSatisfaction: '자기만족',
      convenience:      '편의점',
      etc:              '기타',
    };
    return map[key] ?? '기타';
  }
}

// ── 4. 캐릭터 타입 코드 ─────────────────────────────────────────
// 담당: 파트 3 (안준용) 
class CharacterTypes {
  CharacterTypes._();

  static const String lion   = 'lion';   
  static const String ant    = 'ant';    
  static const String turtle = 'turtle'; 

  static const List<String> all = [lion, ant, turtle];
}

// ── 5. 잔소리 강도 코드 ─────────────────────────────────────────
// 담당: 파트 3 (안준용)
class NaggingIntensity {
  NaggingIntensity._();

  static const String soft   = 'soft';
  static const String normal = 'normal';
  static const String strong = 'strong';

  static const List<String> all = [soft, normal, strong];
}

// ── 6. 예산 상태 코드 ───────────────────────────────────────────
class BudgetState {
  BudgetState._();

  static const String safe    = 'safe';
  static const String warning = 'warning';
  static const String danger  = 'danger';
  static const String over    = 'over';

  /// budgetUsageRate (0.0~100.0) 값을 받아서 상태 코드 반환
  static String fromRate(double rate) {
    if (rate < 50)  return safe;
    if (rate < 80)  return warning;
    if (rate < 100) return danger;
    return over;
  }
}

// ── 7. 위험 지역 카테고리 코드 ──────────────────────────────────
class DangerZoneCategories {
  DangerZoneCategories._();

  static const String mall          = 'mall';
  static const String dept          = 'dept';
  static const String entertainment = 'entertainment';
  static const String cafe          = 'cafe';
  static const String etc           = 'etc';
}

// ── 8. 날짜 포맷 ────────────────────────────────────────────────
class DateFormats {
  DateFormats._();

  static const String yearMonth    = 'yyyy-MM';
  static const String fullDate     = 'yyyy-MM-dd';
  static const String displayDate  = 'MM/dd';
  static const String displayMonth = 'yyyy년 M월';
}