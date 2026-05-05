import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// 앱 전역 컬러 상수 (wallet_saver_app 0405 디자인 기반)
class AppColors {
  AppColors._();

  // ── 브랜드 Primary (보라색 계열)
  static const Color primary = Color(0xFF7C63F5);
  static const Color primaryLight = Color(0xFFA78BFA);
  static const Color primaryDark = Color(0xFF5B46D6);

  // ── 배경 그라디언트 (Hero 카드)
  static const Color gradFrom = Color(0xFF1E1B4B);
  static const Color gradTo = Color(0xFF312E81);

  // ── 상태별 컬러
  static const Color stateSafe = Color(0xFF16A34A);
  static const Color stateOk = Color(0xFF7C63F5);
  static const Color stateCaution = Color(0xFFD97706);
  static const Color stateDanger = Color(0xFFDC2626);
  static const Color stateCritical = Color(0xFFB91C1C);

  // ── 수입 / 지출
  static const Color income = Color(0xFF22C55E);
  static const Color expense = Color(0xFFEF4444);

  // ── 서피스 / 배경
  static const Color white = Color(0xFFFFFFFF);
  static const Color bgPage = Color(0xFFF5F3FF);
  static const Color surface = Color(0xFFF9FAFB);
  static const Color surfaceMuted = Color(0xFFF3F4F6);
  static const Color tagBg = Color(0xFFF0EEFF);

  // ── 텍스트
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF374151);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textMuted = Color(0xFF6B7280);

  // ── 테두리 / 구분선
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ── 카테고리 컬러
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

/// 앱 전역 텍스트 스타일
class AppTextStyles {
  AppTextStyles._();

  static TextStyle pageTitle = GoogleFonts.notoSansKr(
    fontSize: 20, fontWeight: FontWeight.w800,
    color: AppColors.textPrimary, height: 1.3,
  );
  static TextStyle greetingTitle = GoogleFonts.notoSansKr(
    fontSize: 18, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.4,
  );
  static TextStyle heroAmount = GoogleFonts.notoSansKr(
    fontSize: 34, fontWeight: FontWeight.w800,
    color: AppColors.white, letterSpacing: -1.0, height: 1.2,
  );
  static TextStyle cardAmount = GoogleFonts.notoSansKr(
    fontSize: 18, fontWeight: FontWeight.w700, height: 1.3,
  );
  static TextStyle sectionHeader = GoogleFonts.notoSansKr(
    fontSize: 15, fontWeight: FontWeight.w700,
    color: AppColors.textPrimary, height: 1.4,
  );
  static TextStyle listTitle = GoogleFonts.notoSansKr(
    fontSize: 15, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, height: 1.4,
  );
  static TextStyle body = GoogleFonts.notoSansKr(
    fontSize: 14, fontWeight: FontWeight.w400,
    color: AppColors.textSecondary, height: 1.5,
  );
  static TextStyle bodyBold = GoogleFonts.notoSansKr(
    fontSize: 14, fontWeight: FontWeight.w600,
    color: AppColors.textSecondary, height: 1.5,
  );
  static TextStyle caption = GoogleFonts.notoSansKr(
    fontSize: 12, fontWeight: FontWeight.w600,
    color: AppColors.textHint, height: 1.4,
  );
  static TextStyle captionNormal = GoogleFonts.notoSansKr(
    fontSize: 12, fontWeight: FontWeight.w400,
    color: AppColors.textHint, height: 1.4,
  );
  static TextStyle micro = GoogleFonts.notoSansKr(
    fontSize: 10, fontWeight: FontWeight.w500,
    color: AppColors.textHint, height: 1.3,
  );
  static TextStyle chip = GoogleFonts.notoSansKr(
    fontSize: 12, fontWeight: FontWeight.w700, height: 1.3,
  );
  static TextStyle button = GoogleFonts.notoSansKr(
    fontSize: 16, fontWeight: FontWeight.w600,
    color: AppColors.white, height: 1.4,
  );
  static TextStyle navLabel = GoogleFonts.notoSansKr(
    fontSize: 11, fontWeight: FontWeight.w400, height: 1.2,
  );
}

/// 예산 사용률에 따른 테마 (4단계)
class BudgetThemeData {
  final Color primary;
  final Color gradFrom;
  final Color gradTo;
  final String emoji;
  final String label;

  const BudgetThemeData({
    required this.primary,
    required this.gradFrom,
    required this.gradTo,
    required this.emoji,
    required this.label,
  });
}

class AppTheme {
  AppTheme._();

  // 예산 사용률에 따른 테마 (usageRate 기준)
  static BudgetThemeData getBudgetTheme(double usageRate) {
    if (usageRate >= 1.0) {
      return const BudgetThemeData(
        primary: Color(0xFFB91C1C),
        gradFrom: Color(0xFF501313),
        gradTo: Color(0xFF7F1D1D),
        emoji: '😱',
        label: '예산 초과! 당장 멈춰요',
      );
    } else if (usageRate >= 0.8) {
      return const BudgetThemeData(
        primary: Color(0xFFDC2626),
        gradFrom: Color(0xFF7F1D1D),
        gradTo: Color(0xFFA32D2D),
        emoji: '😰',
        label: '위험해요! 조금만 더 아껴요',
      );
    } else if (usageRate >= 0.5) {
      return const BudgetThemeData(
        primary: Color(0xFFD97706),
        gradFrom: Color(0xFF78350F),
        gradTo: Color(0xFFB45309),
        emoji: '😅',
        label: '주의! 예산이 줄고 있어요',
      );
    } else {
      return const BudgetThemeData(
        primary: Color(0xFF7C63F5),
        gradFrom: Color(0xFF1E1B4B),
        gradTo: Color(0xFF312E81),
        emoji: '😊',
        label: '아주 잘하고 있어요!',
      );
    }
  }

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        surface: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.bgPage,
      textTheme: GoogleFonts.notoSansKrTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.notoSansKr(
          fontSize: 20,
          fontWeight: FontWeight.w800,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: GoogleFonts.notoSansKr(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.notoSansKr(fontSize: 15, color: AppColors.textHint),
      ),
    );
  }
}

// ── 유틸: 숫자 포맷 헬퍼
String formatNumber(int n) {
  return n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );
}
