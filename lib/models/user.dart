import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

// Firestore 경로: users/{uid}
// ⚠️ 필드명 임의 변경 금지 — 전 파트 공통 사용
class AppUser {
  final String uid;              // Firebase Auth UID
  final String nickname;         // 앱 내 표시 이름
  final String characterType;    // CharacterTypes 참조
  final int characterLevel;      // 1~5 (기본값 1)
  final int monthlyIncome;       // 월 수입 세후 (원)
  final int monthlyGoal;         // 월 저축/절약 목표 금액 (AI 파트 요청)
  final int age;                 // 나이 (AI 파트 요청)
  final String naggingIntensity; // NaggingIntensity 참조
  final Timestamp createdAt;     // 계정 생성 시각
  final int exp;                 // 경험치 (기본값 0)
  final int level;               // 레벨 (기본값 1, exp 누적으로 상승)

  const AppUser({
    required this.uid,
    required this.nickname,
    required this.characterType,
    required this.characterLevel,
    required this.monthlyIncome,
    required this.monthlyGoal,
    required this.age,
    required this.naggingIntensity,
    required this.createdAt,
    this.exp = 0,
    this.level = 1,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid: d['uid'] as String,
      nickname: d['nickname'] as String,
      characterType: d['characterType'] as String,
      characterLevel: (d['characterLevel'] as num?)?.toInt() ?? 1,
      monthlyIncome: (d['monthlyIncome'] as num).toInt(),
      monthlyGoal: (d['monthlyGoal'] as num?)?.toInt() ?? 0,
      age: (d['age'] as num?)?.toInt() ?? 0,
      naggingIntensity: d['naggingIntensity'] as String? ?? NaggingIntensity.normal,
      createdAt: d['createdAt'] as Timestamp,
      exp: (d['exp'] as num?)?.toInt() ?? 0,
      level: (d['level'] as num?)?.toInt() ?? 1,
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'nickname': nickname,
    'characterType': characterType,
    'characterLevel': characterLevel,
    'monthlyIncome': monthlyIncome,
    'monthlyGoal': monthlyGoal,
    'age': age,
    'naggingIntensity': naggingIntensity,
    'createdAt': createdAt,
    'exp': exp,
    'level': level,
  };

  bool get isValidCharacterType => CharacterTypes.all.contains(characterType);
  bool get isValidNaggingIntensity => NaggingIntensity.all.contains(naggingIntensity);
}
