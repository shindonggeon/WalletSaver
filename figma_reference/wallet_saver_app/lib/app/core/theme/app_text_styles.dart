import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// 앱 전역 텍스트 스타일
/// 폰트: Noto Sans KR (google_fonts)
/// Figma 레퍼런스의 폰트 수치 기반
class AppTextStyles {
  AppTextStyles._();

  // ── 페이지 타이틀 ─────────────────────────────────────────
  /// 가계부, 통계 등 화면 헤더 (20px, w800)
  static TextStyle pageTitle = GoogleFonts.notoSansKr(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  // ── 홈 인사 타이틀 (18px, w700) ───────────────────────────
  static TextStyle greetingTitle = GoogleFonts.notoSansKr(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ── 카드 메인 숫자 (34px, w800) ───────────────────────────
  static TextStyle heroAmount = GoogleFonts.notoSansKr(
    fontSize: 34,
    fontWeight: FontWeight.w800,
    color: AppColors.white,
    letterSpacing: -1.0,
    height: 1.2,
  );

  // ── 카드 서브 숫자 (18px, w700) ───────────────────────────
  static TextStyle cardAmount = GoogleFonts.notoSansKr(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ── 섹션 헤더 (15px, w700) ────────────────────────────────
  static TextStyle sectionHeader = GoogleFonts.notoSansKr(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // ── 리스트 타이틀 (15px, w600) ────────────────────────────
  static TextStyle listTitle = GoogleFonts.notoSansKr(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  // ── 본문 (14px, w400) ─────────────────────────────────────
  static TextStyle body = GoogleFonts.notoSansKr(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── 본문 강조 (14px, w600) ────────────────────────────────
  static TextStyle bodyBold = GoogleFonts.notoSansKr(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // ── 캡션 / 메타 (12px, w600) ─────────────────────────────
  static TextStyle caption = GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textHint,
    height: 1.4,
  );

  // ── 캡션 일반 (12px, w400) ───────────────────────────────
  static TextStyle captionNormal = GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
    height: 1.4,
  );

  // ── 마이크로 (10px, w500) ─────────────────────────────────
  static TextStyle micro = GoogleFonts.notoSansKr(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
    height: 1.3,
  );

  // ── 칩 / 태그 (12px, w700) ───────────────────────────────
  static TextStyle chip = GoogleFonts.notoSansKr(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    height: 1.3,
  );

  // ── 버튼 (16px, w600) ─────────────────────────────────────
  static TextStyle button = GoogleFonts.notoSansKr(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.4,
  );

  // ── 내비게이션 라벨 (11px, w400) ─────────────────────────
  static TextStyle navLabel = GoogleFonts.notoSansKr(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.2,
  );
}
