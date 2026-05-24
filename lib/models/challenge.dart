import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore 경로: users/{uid}/challenges/{docId}
// ⚠️ 필드명 임의 변경 금지 — 전 파트 공통 사용
class Challenge {
  final String id;           // Firestore 문서 ID
  final String title;        // 챌린지 이름
  final String emoji;        // 대표 이모지
  final bool isActive;       // 진행 중 여부
  final Timestamp startedAt; // 챌린지 시작 시각

  const Challenge({
    required this.id,
    required this.title,
    required this.emoji,
    required this.isActive,
    required this.startedAt,
  });

  factory Challenge.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Challenge(
      id: doc.id,
      title: d['title'] as String,
      emoji: d['emoji'] as String? ?? '🎯',
      isActive: d['isActive'] as bool? ?? true,
      startedAt: d['startedAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'emoji': emoji,
    'isActive': isActive,
    'startedAt': startedAt,
  };

  Challenge copyWith({bool? isActive}) => Challenge(
    id: id,
    title: title,
    emoji: emoji,
    isActive: isActive ?? this.isActive,
    startedAt: startedAt,
  );
}
