import 'package:flutter/material.dart';

/// 앱 전역 컬러 상수
/// Figma 레퍼런스에서 추출한 디자인 토큰
class AppColors {
  AppColors._();

  // ── 브랜드 Primary (보라색 계열) ──────────────────────────
  static const Color primary = Color(0xFF7C63F5);        // 메인 보라
  static const Color primaryLight = Color(0xFFA78BFA);   // 그라디언트 끝
  static const Color primaryDark = Color(0xFF5B46D6);    // 눌림 상태

  // ── 배경 그라디언트 (카드) ────────────────────────────────
  static const Color gradFrom = Color(0xFF1E1B4B);       // 딥 퍼플 시작
  static const Color gradTo = Color(0xFF312E81);         // 딥 퍼플 끝

  // ── 태그 / 탭 배경 ────────────────────────────────────────
  static const Color tagBg = Color(0xFFF0EEFF);          // 연보라 칩 배경
  static const Color tabBg = Color(0xFFE9E5FF);          // 탭 바 배경

  // ── 상태별 캐릭터 컬러 ────────────────────────────────────
  static const Color stateSafe = Color(0xFF16A34A);      // 초록 (80% 이상 남음)
  static const Color stateOk = Color(0xFF7C63F5);        // 보라 (60~80%)
  static const Color stateCaution = Color(0xFFD97706);   // 주황 (40~60%)
  static const Color stateDanger = Color(0xFFDC2626);    // 빨강 (20~40%)
  static const Color stateCritical = Color(0xFFB91C1C);  // 진빨강 (20% 미만)

  // ── 수입 / 지출 ──────────────────────────────────────────
  static const Color income = Color(0xFF22C55E);         // 수입 초록
  static const Color expense = Color(0xFFEF4444);        // 지출 빨강

  // ── 서피스 / 배경 ─────────────────────────────────────────
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgPage = Color(0xFFF5F3FF);         // 앱 전체 페이지 배경
  static const Color surface = Color(0xFFF9FAFB);        // 입력 배경
  static const Color surfaceMuted = Color(0xFFF3F4F6);   // Muted 배경

  // ── 텍스트 ───────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);    // 강조 텍스트
  static const Color textSecondary = Color(0xFF374151);  // 본문 텍스트
  static const Color textHint = Color(0xFF9CA3AF);       // 힌트 / 캡션
  static const Color textMuted = Color(0xFF6B7280);      // Muted

  // ── 테두리 / 구분선 ──────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ── 카드 쉐도우 색상 (withOpacity용) ─────────────────────
  static const Color shadowColor = Color(0xFF000000);

  // ── 카테고리 컬러 ─────────────────────────────────────────
  static const Map<String, Color> categoryColors = {
    '식비': Color(0xFFF59E0B),
    '카페': Color(0xFF92400E),
    '쇼핑': Color(0xFF7C63F5),
    '교통': Color(0xFF3B82F6),
    '생활': Color(0xFF10B981),
    '뷰티': Color(0xFFEC4899),
    '구독': Color(0xFF6366F1),
    '기타': Color(0xFF9CA3AF),
    '수입': Color(0xFF22C55E),
  };
}
