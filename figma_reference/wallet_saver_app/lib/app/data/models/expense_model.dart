/// 지출/수입 데이터 모델
class ExpenseModel {
  final String id;
  final String name;         // 장소/메모
  final int amount;          // 지출: 음수, 수입: 양수
  final String category;     // 카테고리 (식비, 카페, 쇼핑, ...)
  final String icon;         // 이모지 아이콘
  final DateTime date;
  final bool isIncome;

  const ExpenseModel({
    required this.id,
    required this.name,
    required this.amount,
    required this.category,
    required this.icon,
    required this.date,
    this.isIncome = false,
  });

  /// 복사본 생성
  ExpenseModel copyWith({
    String? id,
    String? name,
    int? amount,
    String? category,
    String? icon,
    DateTime? date,
    bool? isIncome,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      icon: icon ?? this.icon,
      date: date ?? this.date,
      isIncome: isIncome ?? this.isIncome,
    );
  }

  /// 날짜 그룹용 키 (MM/DD)
  String get dateKey {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$m/$d';
  }

  /// 절댓값 금액
  int get absAmount => amount.abs();
}

/// 더미 지출 데이터 (초기 시연용)
final List<ExpenseModel> dummyExpenses = [
  ExpenseModel(
    id: '1',
    name: '스타벅스',
    amount: -5500,
    category: '카페',
    icon: '☕',
    date: DateTime.now(),
  ),
  ExpenseModel(
    id: '2',
    name: '편의점 CU',
    amount: -3200,
    category: '생활',
    icon: '🏪',
    date: DateTime.now(),
  ),
  ExpenseModel(
    id: '3',
    name: '알바비 입금',
    amount: 600000,
    category: '수입',
    icon: '💰',
    date: DateTime.now().subtract(const Duration(days: 1)),
    isIncome: true,
  ),
  ExpenseModel(
    id: '4',
    name: '치킨마루',
    amount: -19000,
    category: '식비',
    icon: '🍗',
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  ExpenseModel(
    id: '5',
    name: '쿠팡 주문',
    amount: -34000,
    category: '쇼핑',
    icon: '📦',
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ExpenseModel(
    id: '6',
    name: '지하철',
    amount: -1500,
    category: '교통',
    icon: '🚇',
    date: DateTime.now().subtract(const Duration(days: 2)),
  ),
  ExpenseModel(
    id: '7',
    name: '올리브영',
    amount: -28000,
    category: '뷰티',
    icon: '💄',
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
  ExpenseModel(
    id: '8',
    name: '넷플릭스',
    amount: -17000,
    category: '구독',
    icon: '🎬',
    date: DateTime.now().subtract(const Duration(days: 4)),
  ),
  ExpenseModel(
    id: '9',
    name: '맥도날드',
    amount: -12000,
    category: '식비',
    icon: '🍔',
    date: DateTime.now().subtract(const Duration(days: 4)),
  ),
  ExpenseModel(
    id: '10',
    name: '카카오페이',
    amount: -50000,
    category: '기타',
    icon: '💸',
    date: DateTime.now().subtract(const Duration(days: 5)),
  ),
];
