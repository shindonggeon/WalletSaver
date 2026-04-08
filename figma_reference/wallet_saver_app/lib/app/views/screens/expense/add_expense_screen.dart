import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../controllers/expense_controller.dart';
import '../../../controllers/budget_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../data/models/expense_model.dart';
import 'widgets/category_chip_row.dart';

/// 지출 / 수입 입력 화면
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountCtrl = TextEditingController();
  final _memoCtrl = TextEditingController();
  String _selectedCategory = '식비';
  bool _isIncome = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _memoCtrl.dispose();
    super.dispose();
  }

  void _submit() async {
    final amountText = _amountCtrl.text.replaceAll(',', '').trim();
    if (amountText.isEmpty) {
      _showSnack('금액을 입력해주세요');
      return;
    }
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnack('올바른 금액을 입력해주세요');
      return;
    }
    if (_memoCtrl.text.trim().isEmpty) {
      _showSnack('장소 또는 메모를 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 300));

    final expCtrl = Get.find<ExpenseController>();
    final finalAmount = _isIncome ? amount : -amount;
    final category = _isIncome ? '수입' : _selectedCategory;

    expCtrl.addExpense(
      ExpenseModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: _memoCtrl.text.trim(),
        amount: finalAmount,
        category: category,
        icon: _isIncome
            ? '💰'
            : ExpenseController.iconForCategory(_selectedCategory),
        date: DateTime.now(),
        isIncome: _isIncome,
      ),
    );

    _amountCtrl.clear();
    _memoCtrl.clear();
    setState(() {
      _selectedCategory = '식비';
      _isIncome = false;
      _isLoading = false;
    });

    _showSnack('${_isIncome ? '수입' : '지출'}이 기록되었어요 ✅', success: true);
  }

  void _showSnack(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: AppTextStyles.body.copyWith(color: Colors.white)),
        backgroundColor: success ? AppColors.income : AppColors.expense,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final budgetCtrl = Get.find<BudgetController>();

    return Obx(() {
      final theme = budgetCtrl.theme;

      return Scaffold(
        backgroundColor: const Color(0xFFF5F3FF),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── 상단 앱바 ────────────────────────────────────
            SliverAppBar(
              backgroundColor: const Color(0xFFF5F3FF),
              elevation: 0,
              scrolledUnderElevation: 0,
              pinned: false,
              floating: true,
              expandedHeight: 70,
              flexibleSpace: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('지출 추가', style: AppTextStyles.pageTitle),
                    Text(
                      '오늘의 소비를 기록해봐요',
                      style: AppTextStyles.captionNormal,
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // ── 수입/지출 탭 ─────────────────────────
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE9E5FF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        _TypeTab(
                          label: '지출',
                          icon: Icons.trending_down_rounded,
                          isSelected: !_isIncome,
                          color: AppColors.expense,
                          onTap: () => setState(() => _isIncome = false),
                        ),
                        _TypeTab(
                          label: '수입',
                          icon: Icons.trending_up_rounded,
                          isSelected: _isIncome,
                          color: AppColors.income,
                          onTap: () => setState(() => _isIncome = true),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── 금액 입력 ────────────────────────────
                  _SectionLabel(text: '💵 금액'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 18),
                          child: Text(
                            '₩',
                            style: AppTextStyles.greetingTitle.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _amountCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              _ThousandsSeparatorFormatter(),
                            ],
                            style: AppTextStyles.greetingTitle.copyWith(
                              color: AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: '0',
                              hintStyle: AppTextStyles.greetingTitle.copyWith(
                                color: AppColors.textHint,
                              ),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 18,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 18),
                          child: Text(
                            '원',
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.textHint,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── 메모 입력 ────────────────────────────
                  _SectionLabel(text: '📝 장소 / 메모'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _memoCtrl,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: '어디서 쓰셨나요?',
                      prefixIcon: const Icon(
                        Icons.place_outlined,
                        color: AppColors.textHint,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.border,
                          width: 1.5,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── 카테고리 선택 (지출만) ────────────────
                  if (!_isIncome) ...[
                    _SectionLabel(text: '🏷️ 카테고리'),
                    const SizedBox(height: 10),
                    CategoryChipRow(
                      selected: _selectedCategory,
                      onSelect: (c) => setState(() => _selectedCategory = c),
                    ),
                    const SizedBox(height: 28),
                  ] else
                    const SizedBox(height: 28),

                  // ── 등록 버튼 ────────────────────────────
                  GestureDetector(
                    onTap: _isLoading ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _isIncome ? AppColors.income : theme.primary,
                            _isIncome
                                ? const Color(0xFF16A34A)
                                : AppColors.primaryLight,
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: (_isIncome
                                    ? AppColors.income
                                    : theme.primary)
                                .withValues(alpha: 0.45),
                            blurRadius: 20,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                            : Text(
                                _isIncome ? '수입 등록하기' : '지출 등록하기',
                                style: AppTextStyles.button,
                              ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// 섹션 라벨 위젯
class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.sectionHeader.copyWith(
        color: AppColors.textPrimary,
      ),
    );
  }
}

/// 수입/지출 선택 탭 버튼
class _TypeTab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeTab({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : AppColors.textHint,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTextStyles.bodyBold.copyWith(
                  color: isSelected ? Colors.white : AppColors.textHint,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 천 단위 콤마 포맷터
class _ThousandsSeparatorFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final digits = newValue.text.replaceAll(',', '');
    final formatted = _addCommas(digits);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _addCommas(String s) {
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}
