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

  static const Map<String, Map<String, String>> characterData = {
    'lion_shopping': {
      'name': '즉흥적인 쇼퍼',
      'desc': '즉흥적인 쇼퍼 유형입니다! 장바구니에 담아두고 하룻밤 더 고민하는 습관을 가져보세요.',
      'emoji': '🦁',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'lion_convenience': {
      'name': '즉흥적인 편의주의자',
      'desc': '즉흥적인 편의주의자 유형이네요! 편리함에 익숙해져 새나가는 지출을 막기 위해 직접 움직이는 연습이 필요합니다.',
      'emoji': '🦁',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'lion_leisure': {
      'name': '즉흥적인 여행가',
      'desc': '즉흥적인 여행가 유형입니다! 즐거운 여가 뒤에 오는 지출이 부담되지 않도록 전용 비상금을 운용해 보세요.',
      'emoji': '🦁',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'lion_self_satisfaction': {
      'name': '즉흥적인 하비슈머',
      'desc': '즉흥적인 하비슈머 유형이네요! 한꺼번에 많은 비용을 쏟기보다 취미생활의 깊이를 천천히 더해가며 지출을 조절해 보세요.',
      'emoji': '🦁',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f981/512.png',
    },
    'ant_shopping': {
      'name': '계획적인 쇼퍼',
      'desc': '계획적인 쇼퍼 유형이네요! 정해진 예산 안에서 최선의 선택을 내리는 모습이 아주 훌륭합니다!',
      'emoji': '🐜',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png', 
    },
    'ant_convenience': {
      'name': '계획적인 편의주의자',
      'desc': '계획적인 편의주의자 유형입니다! 서비스 활용도와 효율성이 매우 높네요. 지금처럼 스마트하게 관리하시면 됩니다!',
      'emoji': '🐜',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png',
    },
    'ant_leisure': {
      'name': '계획적인 여행가',
      'desc': '계획적인 여행가 유형이네요! 철저한 사전 조사 and 준비성 덕분에 항상 알찬 여가를 보내고 계시군요. 정말 멋집니다!',
      'emoji': '🐜',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png',
    },
    'ant_self_satisfaction': {
      'name': '계획적인 하비슈머',
      'desc': '계획적인 하비슈머 유형입니다! 취미 생활조차 체계적으로 조절하는 절제력이 대단하네요. 지금의 페이스를 유지하세요!',
      'emoji': '🐜',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f41c/512.png',
    },
    'turtle_shopping': {
      'name': '알뜰한 쇼퍼',
      'desc': '알뜰한 쇼퍼 유형입니다! 무조건 저렴한 것만 찾기보다 오래 입을 수 있는 옷에 투자하는 합리적 소비도 고려해 보세요.',
      'emoji': '🐢',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png', 
    },
    'turtle_convenience': {
      'name': '알뜰한 편의주의자',
      'desc': '알뜰한 편의주의자 유형이네요! 지출을 아끼는 것도 좋지만, 가끔은 우리 주변의 편리한 시스템을 적절히 이용해 일상의 여유와 점을 챙겨보세요.',
      'emoji': '🐢',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png',
    },
    'turtle_leisure': {
      'name': '알뜰한 여행가',
      'desc': '알뜰한 여행가 유형입니다! 비용을 줄이는 데만 몰두하기보다 본인의 즐거움을 위해 적당한 여가 생활을 누려보세요.',
      'emoji': '🐢',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png',
    },
    'turtle_self_satisfaction': {
      'name': '알뜰한 하비슈머',
      'desc': '알뜰한 하비슈머 유형이네요! 비용을 아끼는 것도 좋지만 취미의 질을 높여줄 핵심적인 부분에는 적당히 지출해 보는 것도 추천합니다.',
      'emoji': '🐢',
      'imageUrl': 'https://fonts.gstatic.com/s/e/notoemoji/latest/1f422/512.png',
    },
  };
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