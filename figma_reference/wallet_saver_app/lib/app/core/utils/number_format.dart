import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show NumberFormat;
import '../theme/app_colors.dart';

/// 금액 포맷 유틸
class NumberFormatUtil {
  NumberFormatUtil._();

  static final _formatter = NumberFormat('#,###');

  /// 12345 → "12,345원"
  static String formatWon(int amount) {
    return '${_formatter.format(amount)}원';
  }

  /// 12345 → "12,345"
  static String format(int amount) {
    return _formatter.format(amount);
  }

  /// 12345 → "1.2만원"
  static String formatManWon(int amount) {
    final man = amount / 10000;
    if (man >= 1) {
      return '${man.toStringAsFixed(1)}만원';
    }
    return '${_formatter.format(amount)}원';
  }

  /// 지출 금액 색상 반환
  static Color getAmountColor(int amount) {
    return amount < 0 ? AppColors.expense : AppColors.income;
  }

  /// 지출/수입 접두사 반환
  static String formatWithSign(int amount) {
    return amount > 0
        ? '+${_formatter.format(amount)}원'
        : '${_formatter.format(amount)}원';
  }
}
