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

  /// 챌린지 달성 시 XP 추가 및 레벨업 체크 (트랜잭션 사용)
  /// 반환값: 레벨업 시 새로운 레벨을 반환, 아니면 null 반환
  static Future<int?> addXp({
    required String uid,
    required int xpAmount,
  }) async {
    final userRef = _userRef(uid);
    int? leveledUpTo;

    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(userRef);
      if (!snapshot.exists) return;

      final data = snapshot.data()!;
      final currentLevel = data['level'] as int? ?? 1;
      final currentXp = data['exp'] as int? ?? 0;

      final newXp = currentXp + xpAmount;
      // 레벨 계산: 1->2 (30XP), 2->3 (50XP) ... 
      // 좀 더 명확하게 레벨마다 필요한 최대 경험치를 별도로 계산
      final requiredXp = currentLevel * 20 + 10; // Lv1: 30, Lv2: 50, Lv3: 70 ...

      if (newXp >= requiredXp) {
        // 레벨업 발생
        final nextLevel = currentLevel + 1;
        final remainderXp = newXp - requiredXp;
        
        transaction.set(userRef, {
          'level': nextLevel,
          'exp': remainderXp,
        }, SetOptions(merge: true));
        
        leveledUpTo = nextLevel;
      } else {
        // 경험치만 증가
        transaction.set(userRef, {
          'exp': newXp,
        }, SetOptions(merge: true));
      }
    });

    return leveledUpTo;
  }

  /// 특정 레벨에 필요한 경험치 계산 헬퍼
  static int getRequiredXp(int level) {
    return level * 20 + 10;
  }
}
