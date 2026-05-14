// ════════════════════════════════════════════════════════════════════
// lib/constants/app_constants.dart
//
// 소리 (Sori) 앱 공통 상수 파일
//
// ⚠️  주의사항
//     - 이 파일의 값을 직접 수정하면 전 파트에 영향을 줍니다.
//     - 수정 전 반드시 팀장(신동건)과 협의해주세요.
//     - 값은 반드시 소문자 영어로 작성해주세요.
//
// ✅  사용법
//     import '../constants/app_constants.dart';
//
//     category: CategoryKeys.food          // ✅ 올바른 사용
//     category: 'food'                     // ❌ 하드코딩 금지
//
// 📌  파트별 담당 구역
//     CollectionKeys   → 파트 2 (송종민) 확정 후 수정
//     BudgetKeys       → 파트 2 (송종민) 확정 후 수정
//     CategoryKeys     → 파트 2 (송종민) 확정 후 수정
//     CharacterTypes   → 파트 3 (안준용) 확정 후 추가
//     NaggingIntensity → 파트 3 (안준용) 확정 후 추가
//     BudgetState      → 파트 5 (신동건) 관리
//     DangerZoneCategories → 파트 1 (김동원) 확정 후 추가
//     DateFormats      → 공통
// ════════════════════════════════════════════════════════════════════

// ── 1. Firestore 컬렉션명 ────────────────────────────────────────
// 담당: 파트 2 (송종민)
// 사용: 전 파트
// TODO (송종민): 컬렉션명 확정되면 값 검토 후 수정해줘
class CollectionKeys {
  CollectionKeys._();

  static const String users            = 'users';           // 사용자 정보
  static const String expenses         = 'expenses';        // 지출 내역
  static const String budgets          = 'budgets';         // 월별 예산
  static const String fixedExpenses    = 'fixedExpenses';   // 고정 지출
  static const String challenges       = 'challenges';      // 절제 챌린지
  static const String dangerZones      = 'dangerZones';     // 위험 지역
}

// ── 2. Firestore 필드명 (예산 관련) ─────────────────────────────
// 담당: 파트 2 (송종민)
// 사용: 파트 1 (GPS), 파트 4 (AI), 파트 5 (UI)
// ⚠️  이 3개 필드명은 전 파트가 의존합니다. 확정 즉시 단톡 공유 필수!
// TODO (송종민): 필드명 확정되면 값 검토 후 수정해줘
class BudgetKeys {
  BudgetKeys._();

  static const String totalBudget      = 'totalBudget';      // 이번 달 총 예산
  static const String totalSpent       = 'totalSpent';       // 이번 달 누적 지출
  static const String remainingBudget  = 'remainingBudget';  // 잔여 예산
  static const String todayBudget      = 'todayBudget';      // 오늘 쓸 수 있는 돈
  static const String budgetUsageRate  = 'budgetUsageRate';  // 예산 사용률 (0.0~1.0)
}

// ── 3. 지출 카테고리 코드 ────────────────────────────────────────
// 담당: 파트 2 (송종민)
// 사용: 파트 2 (저장), 파트 4 (분석), 파트 5 (필터 칩)
// TODO (송종민): 카테고리 확정되면 값 검토 후 수정해줘
class CategoryKeys {
  CategoryKeys._();

  static const String food             = 'food';             // 식비
  static const String cafe             = 'cafe';             // 카페
  static const String shopping         = 'shopping';         // 쇼핑
  static const String transport        = 'transport';        // 교통
  static const String living           = 'living';           // 생활
  static const String etc              = 'etc';              // 기타
}

// ── 4. 캐릭터 타입 코드 ─────────────────────────────────────────
// 담당: 파트 3 (안준용)
// 사용: 파트 3 (저장), 파트 4 (프롬프트 분기), 파트 5 (UI)
// TODO (안준용): 캐릭터 확정되면 아래 값 채워줘
class CharacterTypes {
  CharacterTypes._();

  static const String squirrel         = 'squirrel';         // 충동적 다람쥐
  static const String ant              = 'ant';              // 계획적 개미
  static const String lion             = 'lion';             // 기분파 사자
  static const String beaver           = 'beaver';           // 절약형 비버
}

// ── 5. 잔소리 강도 코드 ─────────────────────────────────────────
// 담당: 파트 3 (안준용)
// 사용: 파트 3 (설정 저장), 파트 4 (프롬프트 강도 분기)
// TODO (안준용): 강도 단계 확정되면 아래 값 채워줘
class NaggingIntensity {
  NaggingIntensity._();

  static const String soft             = 'soft';             // 부드럽게
  static const String normal           = 'normal';           // 적당히
  static const String strong           = 'strong';           // 강하게
}

// ── 6. 예산 상태 코드 ───────────────────────────────────────────
// 담당: 파트 5 (신동건)
// 사용: 파트 4 (잔소리 강도 판단), 파트 5 (UI 테마 전환)
// 기준: budgetUsageRate 값에 따라 자동 분기
class BudgetState {
  BudgetState._();

  static const String safe             = 'safe';             // 안전 — 50% 미만  → 보라
  static const String warning          = 'warning';          // 주의 — 50~79%   → 주황
  static const String danger           = 'danger';           // 위험 — 80~99%   → 빨강
  static const String over             = 'over';             // 초과 — 100% 이상 → 진빨강

  /// budgetUsageRate(0.0~1.0) 값을 받아서 상태 코드 반환
  static String fromRate(double rate) {
    if (rate < 0.5)  return safe;
    if (rate < 0.8)  return warning;
    if (rate < 1.0)  return danger;
    return over;
  }
}

// ── 7. 위험 지역 카테고리 코드 ──────────────────────────────────
// 담당: 파트 1 (김동원)
// 사용: 파트 1 (저장), 파트 4 (잔소리 문구 생성 시 참고)
// TODO (김동원): 위험 지역 카테고리 확정되면 아래 값 채워줘
class DangerZoneCategories {
  DangerZoneCategories._();

  static const String mall             = 'mall';             // 쇼핑몰
  static const String dept             = 'dept';             // 백화점
  static const String entertainment    = 'entertainment';    // 유흥
  static const String cafe             = 'cafe';             // 카페 거리
  static const String etc              = 'etc';              // 기타
}

// ── 8. 날짜 포맷 ────────────────────────────────────────────────
// 담당: 공통
// 사용: 파트 2 (budgets 문서 ID), 파트 3 (challenges.yearMonth)
class DateFormats {
  DateFormats._();

  static const String yearMonth        = 'yyyy-MM';          // 예: 2026-04
  static const String fullDate         = 'yyyy-MM-dd';       // 예: 2026-04-02
  static const String displayDate      = 'MM/dd';            // 예: 04/02 (화면 표시용)
  static const String displayMonth     = 'yyyy년 M월';        // 예: 2026년 4월 (화면 표시용)
}
