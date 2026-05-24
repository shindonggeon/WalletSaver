import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/app_constants.dart';

// Firestore 경로: users/{uid}/expenses/{docId}
// ⚠️ 필드명 임의 변경 금지 — 전 파트 공통 사용
class Expense {
  final String id;
  final int amount;         // 지출 금액 (원, 양수)
  final String category;   // CategoryKeys 참조
  final String merchant;   // 가맹점명 (예: 스타벅스)
  final String? memo;      // 메모 (선택)
  final bool isAuto;       // SMS 자동 파싱 여부
  final Timestamp spentAt; // 지출 발생 시각

  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.merchant,
    this.memo,
    required this.isAuto,
    required this.spentAt,
  });

  factory Expense.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      amount: (d['amount'] as num).toInt(),
      category: d['category'] as String,
      merchant: d['merchant'] as String,
      memo: d['memo'] as String?,
      isAuto: d['isAuto'] as bool? ?? false,
      spentAt: d['spentAt'] as Timestamp,
    );
  }

  Map<String, dynamic> toMap() => {
    'amount': amount,
    'category': category,
    'merchant': merchant,
    if (memo != null && memo!.isNotEmpty) 'memo': memo,
    'isAuto': isAuto,
    'spentAt': spentAt,
  };

  // 유효 카테고리 목록은 CategoryKeys.all 참조
  static bool isValidCategory(String category) =>
      CategoryKeys.all.contains(category);
}
