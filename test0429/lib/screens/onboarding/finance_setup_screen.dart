import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import '../../services/user_service.dart';

class FinanceSetupScreen extends StatefulWidget {
  final String characterType;
  const FinanceSetupScreen({super.key, required this.characterType});

  @override
  State<FinanceSetupScreen> createState() => _FinanceSetupScreenState();
}

class _FinanceSetupScreenState extends State<FinanceSetupScreen> {
  final _incomeController = TextEditingController();
  final List<Map<String, dynamic>> _fixedExpenses = [
    {'name': '월세', 'amount': 500000},
    {'name': '통신비', 'amount': 60000},
    {'name': '구독료', 'amount': 15000},
  ];
  bool _isSaving = false;

  int get _income => int.tryParse(_incomeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get _totalFixed => _fixedExpenses.fold(0, (s, e) => s + (e['amount'] as int));
  int get _available => _income - _totalFixed;

  @override
  void dispose() {
    _incomeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_income <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('월 수입을 입력해주세요.')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    setState(() => _isSaving = true);
    try {
      await UserService.saveFinanceSetup(
        uid: uid,
        monthlyIncome: _income,
        fixedExpenses: _fixedExpenses,
      ).timeout(const Duration(seconds: 3));
      
      if (mounted) context.push('/onboarding/challenge-setup', extra: {
        'characterType': widget.characterType,
        'monthlyIncome': _income,
        'fixedExpenses': _totalFixed,
      });
    } catch (e) {
      print('저장 실패 (무시하고 넘어감): $e');
      // 타임아웃이 나거나 권한 에러가 나도, 발표 시연을 위해 강제로 다음 화면으로 넘깁니다.
      if (mounted) {
        context.push('/onboarding/challenge-setup', extra: {
          'characterType': widget.characterType,
          'monthlyIncome': _income,
          'fixedExpenses': _totalFixed,
        });
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _addFixedExpense(String name, int amount) {
    setState(() {
      _fixedExpenses.add({'name': name, 'amount': amount});
    });
  }

  void _removeFixedExpense(int index) {
    setState(() {
      _fixedExpenses.removeAt(index);
    });
  }

  void _showAddExpenseDialog() {
    final nameCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('고정 지출 추가', style: AppTextStyles.bodyBold),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: '항목명')),
            const SizedBox(height: 8),
            TextField(controller: amountCtrl, decoration: const InputDecoration(labelText: '금액'), keyboardType: TextInputType.number),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
          TextButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final amount = int.tryParse(amountCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
              if (name.isNotEmpty && amount > 0) {
                _addFixedExpense(name, amount);
                Navigator.pop(context);
              }
            },
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        title: Text('재무 설정', style: AppTextStyles.pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '월 평균 수입은\n얼마인가요?',
                    style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _incomeController,

                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: '예: 2500000',
                      suffixText: '원',
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('고정 지출', style: AppTextStyles.sectionHeader),
                      TextButton.icon(
                        onPressed: _showAddExpenseDialog,
                        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                        label: Text(
                          '추가',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._fixedExpenses.asMap().entries.map(
                    (entry) => _ExpenseItem(
                      name: entry.value['name'] as String,
                      amount: entry.value['amount'] as int,
                      onDelete: () => _removeFixedExpense(entry.key),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // 하단: 예산 표시 + 저장 버튼
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -4),
                  blurRadius: 12,
                )
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '사용 가능 예산',
                      style: AppTextStyles.bodyBold.copyWith(color: AppColors.textMuted),
                    ),
                    Text(
                      '${formatNumber(_available)}원',
                      style: AppTextStyles.cardAmount.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    child: _isSaving
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('다음으로'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpenseItem extends StatelessWidget {
  final String name;
  final int amount;
  final VoidCallback onDelete;
  const _ExpenseItem({
    required this.name,
    required this.amount,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(name, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
            ),
            Text('${formatNumber(amount)}원', style: AppTextStyles.bodyBold),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppColors.expense, size: 20),
              onPressed: onDelete,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}
