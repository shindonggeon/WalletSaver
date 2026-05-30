import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

// users/{uid} 문서 및 users/{uid}/fixedExpenses 서브컬렉션 관리
class UserService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection(CollectionKeys.users).doc(uid);

  static CollectionReference<Map<String, dynamic>> _fixedExpensesRef(String uid) =>
      _userRef(uid).collection(CollectionKeys.fixedExpenses);

  // ─── 재무 설정 저장 ────────────────────────────────────────────────────────

  /// 재무설정 화면에서 호출: 월 수입 + 고정지출 목록을 Firestore에 저장
  ///
  /// [fixedExpenses] 형식: [{'name': '월세', 'amount': 500000}, ...]
  static Future<void> saveFinanceSetup({
    required String uid,
    required int monthlyIncome,
    required List<Map<String, dynamic>> fixedExpenses,
  }) async {
    // users/{uid} 문서에 monthlyIncome 업데이트 (merge: true → 다른 필드 유지)
    await _userRef(uid).set(
      {'monthlyIncome': monthlyIncome},
      SetOptions(merge: true),
    );

    // 기존 fixedExpenses 전체 삭제 후 새로 저장 (배치 처리)
    final existing = await _fixedExpensesRef(uid).get();
    final batch = _db.batch();
    for (final doc in existing.docs) {
      batch.delete(doc.reference);
    }
    for (final expense in fixedExpenses) {
      batch.set(_fixedExpensesRef(uid).doc(), {
        'name': expense['name'] as String,
        'amount': (expense['amount'] as num).toInt(),
      });
    }
    await batch.commit();
  }

  // ─── 재무 설정 조회 ────────────────────────────────────────────────────────

  /// 고정지출 합계 반환 (BudgetService.addExpense()의 fixedExpenses 파라미터에 사용)
  static Future<int> getTotalFixedExpenses(String uid) async {
    final snap = await _fixedExpensesRef(uid).get();
    return snap.docs.fold<int>(
      0,
      (acc, doc) => acc + (doc.data()['amount'] as num).toInt(),
    );
  }

  /// 고정지출 목록 스트림
  static Stream<List<Map<String, dynamic>>> fixedExpensesStream(String uid) {
    return _fixedExpensesRef(uid).snapshots().map(
      (snap) => snap.docs
          .map((doc) => {
                'name': doc.data()['name'] as String,
                'amount': doc.data()['amount'] as int,
              })
          .toList(),
    );
  }

  // ─── exp / level / character 업데이트 ──────────────────────────────────────

  /// 캐릭터 성향 저장 (온보딩 결과에서 호출)
  static Future<void> updateCharacterType({
    required String uid,
    required String characterType,
  }) async {
    await _userRef(uid).set(
      {'characterType': characterType},
      SetOptions(merge: true),
    );
  }

  /// 캐릭터 경험치·레벨 갱신 (챌린지 달성, 지출 절제 시 호출)
  static Future<void> updateExpAndLevel({
    required String uid,
    required int exp,
    required int level,
  }) async {
    await _userRef(uid).set(
      {'exp': exp, 'level': level},
      SetOptions(merge: true),
    );
  }

  /// exp 누적 후 레벨 계산: 100 exp마다 1레벨 상승
  static int calcLevel(int exp) => (exp ~/ 100) + 1;
}
