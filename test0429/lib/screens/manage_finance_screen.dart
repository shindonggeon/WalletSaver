import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/user_service.dart';
import '../services/budget_service.dart';
import '../constants/app_constants.dart';

class ManageFinanceScreen extends StatefulWidget {
  const ManageFinanceScreen({super.key});

  @override
  State<ManageFinanceScreen> createState() => _ManageFinanceScreenState();
}

class _ManageFinanceScreenState extends State<ManageFinanceScreen> {
  final _incomeController = TextEditingController();
  List<Map<String, dynamic>> _fixedExpenses = [];
  bool _isLoading = true;
  bool _isSaving = false;

  int get _income => int.tryParse(_incomeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
  int get _totalFixed => _fixedExpenses.fold(0, (s, e) => s + (e['amount'] as int));
  int get _available => _income - _totalFixed;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    
    try {
      final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
      final income = userDoc.data()?['monthlyIncome'] as int? ?? 0;
      _incomeController.text = income > 0 ? income.toString() : '';

      final expensesSnap = await FirebaseFirestore.instance
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.fixedExpenses)
          .get();
          
      _fixedExpenses = expensesSnap.docs.map((doc) => {
        'name': doc.data()['name'] as String,
        'amount': (doc.data()['amount'] as num).toInt(),
      }).toList();
    } catch (e) {
      debugPrint('Error loading finance data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

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
      );
      
      // Update Budget
      await BudgetService.recalculateAndSave(
        uid: uid,
        monthlyIncome: _income,
        fixedExpenses: _totalFixed,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('저장되었습니다.')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('저장 실패: $e')),
        );
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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.bgPage,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        title: Text('고정 지출 및 수입 관리', style: AppTextStyles.pageTitle),
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
                    '월 평균 수입',
                    style: AppTextStyles.sectionHeader,
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
                      '${_available.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원',
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
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Text('저장하기'),
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
            Text('${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}원', style: AppTextStyles.bodyBold),
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
