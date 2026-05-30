import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/budget.dart';
import '../models/expense.dart';

class BudgetService {
  static final _db = FirebaseFirestore.instance;

  // ─── 날짜 헬퍼 ──────────────────────────────────────────────────────────────

  /// 현재 월을 'YYYY-MM' 형식으로 반환 (budgets 문서 ID)
  static String currentYearMonth() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}';
  }

  /// 이번 달 남은 일수 (오늘 포함)
  static int daysLeftInMonth() {
    final now = DateTime.now();
    final lastDay = DateTime(now.year, now.month + 1, 0).day;
    return lastDay - now.day + 1;
  }

  // ─── Firestore 경로 헬퍼 ───────────────────────────────────────────────────

  static CollectionReference<Map<String, dynamic>> _expensesRef(String uid) =>
      _db
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.expenses);

  static DocumentReference<Map<String, dynamic>> _budgetRef(
    String uid, [
    String? yearMonth,
  ]) =>
      _db
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.budgets)
          .doc(yearMonth ?? currentYearMonth());

  // ─── 지출 CRUD ─────────────────────────────────────────────────────────────

  /// 지출 추가 후 해당 월 budget 문서를 자동으로 갱신
  static Future<void> addExpense({
    required String uid,
    required Expense expense,
    required int monthlyIncome,
    required int fixedExpenses,
  }) async {
    await _expensesRef(uid).add(expense.toMap());
    await recalculateAndSave(
      uid: uid,
      monthlyIncome: monthlyIncome,
      fixedExpenses: fixedExpenses,
    );
  }

  /// 지출 삭제 후 budget 갱신
  static Future<void> deleteExpense({
    required String uid,
    required String expenseId,
    required int monthlyIncome,
    required int fixedExpenses,
  }) async {
    await _expensesRef(uid).doc(expenseId).delete();
    await recalculateAndSave(
      uid: uid,
      monthlyIncome: monthlyIncome,
      fixedExpenses: fixedExpenses,
    );
  }

  // ─── 예산 계산 & 저장 ──────────────────────────────────────────────────────

  /// 이번 달 지출 합산 → Budget 수식 적용 → Firestore 저장
  static Future<Budget> recalculateAndSave({
    required String uid,
    required int monthlyIncome,
    required int fixedExpenses,
  }) async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);

    final snapshot = await _expensesRef(uid)
        .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .get();

    int totalSpentBeforeToday = 0;
    int spentToday = 0;
    
    final todayStart = DateTime(now.year, now.month, now.day);

    for (var doc in snapshot.docs) {
      final amount = (doc.data()['amount'] as num).toInt();
      final spentAt = (doc.data()['spentAt'] as Timestamp).toDate();
      
      if (spentAt.isBefore(todayStart)) {
        totalSpentBeforeToday += amount;
      } else {
        spentToday += amount;
      }
    }

    final budget = Budget.calculate(
      monthlyIncome: monthlyIncome,
      fixedExpenses: fixedExpenses,
      totalSpentBeforeToday: totalSpentBeforeToday,
      spentToday: spentToday,
      daysLeftInMonth: daysLeftInMonth(),
    );

    await _budgetRef(uid).set(budget.toMap());
    return budget;
  }

  // ─── 스트림 ────────────────────────────────────────────────────────────────

  /// 이번 달 지출 목록 실시간 스트림
  static Stream<List<Expense>> expenseStream(String uid) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    return _expensesRef(uid)
        .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
        .orderBy('spentAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(Expense.fromDoc).toList());
  }

  /// 이번 달 예산 문서 실시간 스트림
  static Stream<Budget?> budgetStream(String uid) {
    return _budgetRef(uid).snapshots().map(
      (doc) => doc.exists ? Budget.fromDoc(doc) : null,
    );
  }

  // ─── 카테고리 분류 ─────────────────────────────────────────────────────────

  /// 가맹점명을 보고 CategoryKeys 코드를 반환
  static String classifyCategory(String merchant) {
    const cafeKeywords = [
      '스타벅스', '이디야', '메가커피', '투썸플레이스', '커피빈', '폴바셋', '할리스',
      '탐앤탐스', '빽다방', '카페베네', '더리터', '더벤티', '컴포즈커피', '블루보틀',
      '바샤커피', '맥카페', '파스쿠찌', '카페', '커피',
    ];
    const shoppingKeywords = [
      '쿠팡', '올리브영', '다이소', '무신사', 'H&M', 'ZARA', '자라', '유니클로',
      'ABC마트', '나이키', '아디다스', '배민', '요기요', '마켓', '백화점', '스타필드',
    ];
    const transportKeywords = [
      '버스', '지하철', '택시', 'KTX', 'SRT', '기차', 'T머니', '카카오택시', '우버',
    ];
    const livingKeywords = [
      '넷플릭스', '유튜브프리미엄', '스포티파이', '왓챠', '웨이브', '티빙', '구독',
      '전기', '수도', '가스', '통신', '인터넷', '월세', '관리비',
    ];
    const leisureKeywords = [
      '영화', 'CGV', '롯데시네마', '메가박스', '볼링', '노래방', '당구', '게임',
      '스크린', '클라이밍', '수영', '헬스', '피트니스', '스포츠',
    ];
    const selfSatisfactionKeywords = [
      '미용실', '네일', '피부과', '에스테틱', '마사지', '향수', '화장품', '악기',
      '책', '교보문고', '알라딘', '예스24',
    ];
    const convenienceKeywords = [
      'GS25', 'CU', '세븐일레븐', '미니스톱', '이마트24', '편의점',
    ];
    const foodKeywords = [
      '맥도날드', '롯데리아', '버거킹', 'KFC', '서브웨이', '맘스터치', '피자헛', '도미노',
      '치킨', '족발', '보쌈', '삼겹살', '식당', '한식', '중식', '일식', '분식',
      '이마트', '홈플러스', '롯데마트', '코스트코', '마트', '슈퍼',
    ];

    if (cafeKeywords.any(merchant.contains)) return CategoryKeys.cafe;
    if (convenienceKeywords.any(merchant.contains)) return CategoryKeys.convenience;
    if (shoppingKeywords.any(merchant.contains)) return CategoryKeys.shopping;
    if (transportKeywords.any(merchant.contains)) return CategoryKeys.transport;
    if (livingKeywords.any(merchant.contains)) return CategoryKeys.living;
    if (leisureKeywords.any(merchant.contains)) return CategoryKeys.leisure;
    if (selfSatisfactionKeywords.any(merchant.contains)) return CategoryKeys.selfSatisfaction;
    if (foodKeywords.any(merchant.contains)) return CategoryKeys.food;
    return CategoryKeys.etc;
  }
}
