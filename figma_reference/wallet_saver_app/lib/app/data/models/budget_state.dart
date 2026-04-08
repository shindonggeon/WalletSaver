import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// 예산 상태 열거형
/// 예산 잔여 비율에 따라 5단계로 분류
enum BudgetState {
  safe,     // 80% 이상 남음
  ok,       // 60~80%
  caution,  // 40~60%
  danger,   // 20~40%
  critical, // 20% 미만
}

/// BudgetState별 테마 데이터
class BudgetThemeData {
  final Color primary;
  final Color gradFrom;
  final Color gradTo;
  final Color cardBg;
  final String label;
  final String emoji;
  final String nagMessage;

  const BudgetThemeData({
    required this.primary,
    required this.gradFrom,
    required this.gradTo,
    required this.cardBg,
    required this.label,
    required this.emoji,
    required this.nagMessage,
  });
}

const Map<BudgetState, BudgetThemeData> budgetThemeMap = {
  BudgetState.safe: BudgetThemeData(
    primary: AppColors.stateSafe,
    gradFrom: Color(0xFF14532D),
    gradTo: Color(0xFF16A34A),
    cardBg: Color(0xFFDCFCE7),
    label: '여유로운 상태예요!',
    emoji: '😊',
    nagMessage: '잘 하고 있어요! 이 페이스 유지하면 이번 달 목표 달성할 수 있어요 🎉',
  ),
  BudgetState.ok: BudgetThemeData(
    primary: AppColors.stateOk,
    gradFrom: Color(0xFF1E1B4B),
    gradTo: Color(0xFF312E81),
    cardBg: Color(0xFFF0EEFF),
    label: '편안한 상태예요',
    emoji: '😌',
    nagMessage: '스타필드 코엑스 반경 100m입니다! 들어가기 전에 예산 확인해요 💜',
  ),
  BudgetState.caution: BudgetThemeData(
    primary: AppColors.stateCaution,
    gradFrom: Color(0xFF78350F),
    gradTo: Color(0xFFD97706),
    cardBg: Color(0xFFFEF9E7),
    label: '조금 주의가 필요해요',
    emoji: '😐',
    nagMessage: '⚠️ 예산의 60%를 썼어요. 이번주는 배달 주문 줄여보는 건 어때요?',
  ),
  BudgetState.danger: BudgetThemeData(
    primary: AppColors.stateDanger,
    gradFrom: Color(0xFF7F1D1D),
    gradTo: Color(0xFFDC2626),
    cardBg: Color(0xFFFEE2E2),
    label: '위험해요! 지출을 줄여요',
    emoji: '😰',
    nagMessage: '🚨 위험! 예산의 80%를 사용했어요. 지금 당장 지출을 멈춰야 해요!',
  ),
  BudgetState.critical: BudgetThemeData(
    primary: AppColors.stateCritical,
    gradFrom: Color(0xFF450A0A),
    gradTo: Color(0xFFB91C1C),
    cardBg: Color(0xFFFECACA),
    label: '예산 초과 직전이에요!!',
    emoji: '😱',
    nagMessage: '💀 예산 초과 직전이에요!! 제발요... 지갑 닫고 집에 가세요!!!',
  ),
};

/// 잔여 비율(0~100)로 BudgetState 반환
BudgetState getBudgetState(double remainPct) {
  if (remainPct >= 80) return BudgetState.safe;
  if (remainPct >= 60) return BudgetState.ok;
  if (remainPct >= 40) return BudgetState.caution;
  if (remainPct >= 20) return BudgetState.danger;
  return BudgetState.critical;
}
