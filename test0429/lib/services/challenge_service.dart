import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';
import '../models/challenge.dart';

// users/{uid}/challenges 컬렉션 CRUD
class ChallengeService {
  static final _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> _ref(String uid) =>
      _db
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.challenges);

  // ─── Create ────────────────────────────────────────────────────────────────

  /// 챌린지 1개 생성, 생성된 문서 ID 반환
  static Future<String> createChallenge({
    required String uid,
    required Challenge challenge,
  }) async {
    final ref = await _ref(uid).add(challenge.toMap());
    return ref.id;
  }

  /// 온보딩 화면에서 여러 챌린지 일괄 생성 (배치 처리)
  static Future<void> createChallenges({
    required String uid,
    required List<Challenge> challenges,
  }) async {
    if (challenges.isEmpty) return;
    final batch = _db.batch();
    for (final c in challenges) {
      batch.set(_ref(uid).doc(), c.toMap());
    }
    await batch.commit();
  }

  // ─── Read ──────────────────────────────────────────────────────────────────

  /// 활성 챌린지 실시간 스트림 (isActive == true)
  static Stream<List<Challenge>> activeChallengesStream(String uid) {
    return _ref(uid)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(Challenge.fromDoc).toList();
          list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return list;
        });
  }

  /// 전체 챌린지 실시간 스트림
  static Stream<List<Challenge>> allChallengesStream(String uid) {
    return _ref(uid)
        .snapshots()
        .map((snap) {
          final list = snap.docs.map(Challenge.fromDoc).toList();
          list.sort((a, b) => b.startedAt.compareTo(a.startedAt));
          return list;
        });
  }

  // ─── Update ────────────────────────────────────────────────────────────────

  /// 챌린지 필드 부분 업데이트
  static Future<void> updateChallenge({
    required String uid,
    required String challengeId,
    required Map<String, dynamic> data,
  }) async {
    await _ref(uid).doc(challengeId).update(data);
  }

  /// 챌린지 완료 처리 및 유저 레벨업
  static Future<void> completeChallenge({
    required String uid,
    required String challengeId,
  }) async {
    final batch = _db.batch();
    
    // 1. 챌린지 비활성화
    final challengeRef = _ref(uid).doc(challengeId);
    batch.update(challengeRef, {'isActive': false});

    // 2. 유저 레벨 증가
    final userRef = _db.collection(CollectionKeys.users).doc(uid);
    batch.update(userRef, {'level': FieldValue.increment(1)});

    await batch.commit();
  }

  // ─── Delete ────────────────────────────────────────────────────────────────

  /// 챌린지 삭제
  static Future<void> deleteChallenge({
    required String uid,
    required String challengeId,
  }) async {
    await _ref(uid).doc(challengeId).delete();
  }
}
