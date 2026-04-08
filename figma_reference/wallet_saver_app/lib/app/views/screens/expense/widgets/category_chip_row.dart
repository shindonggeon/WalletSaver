import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

/// 카테고리 선택 Wrap 위젯
class CategoryChipRow extends StatelessWidget {
  final String selected;
  final void Function(String) onSelect;

  const CategoryChipRow({
    super.key,
    required this.selected,
    required this.onSelect,
  });

  static const List<String> categories = [
    '식비', '카페', '쇼핑', '교통', '생활', '뷰티', '구독', '기타',
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat == selected;
        final catColor =
            AppColors.categoryColors[cat] ?? AppColors.primary;

        return GestureDetector(
          onTap: () => onSelect(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? catColor : catColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? catColor
                    : catColor.withValues(alpha: 0.25),
                width: 1.5,
              ),
            ),
            child: Text(
              cat,
              style: AppTextStyles.chip.copyWith(
                color: isSelected ? Colors.white : catColor,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
