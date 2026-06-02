import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../models/expense.dart';
import '../services/budget_service.dart';
import '../constants/app_constants.dart';

void showAddExpenseBottomSheet(BuildContext context, String uid) {
  bool isIncome = false;
  String selectedCat = CategoryKeys.food; // Default expense category
  final merchantController = TextEditingController();
  final amountController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgPage,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 20, right: 20, top: 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('내역 추가', style: AppTextStyles.pageTitle),
                    // 지출 / 수입 토글
                    Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.tagBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => setModalState(() => isIncome = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: !isIncome ? AppColors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: !isIncome ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                              ),
                              child: Text('지출', style: AppTextStyles.caption.copyWith(
                                color: !isIncome ? AppColors.primary : AppColors.textHint,
                              )),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setModalState(() => isIncome = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isIncome ? AppColors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: isIncome ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : [],
                              ),
                              child: Text('수입', style: AppTextStyles.caption.copyWith(
                                color: isIncome ? AppColors.primary : AppColors.textHint,
                              )),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                if (!isIncome) ...[
                  Text('카테고리', style: AppTextStyles.bodyBold),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: CategoryKeys.all.where((c) => c != CategoryKeys.income).map((cat) {
                        final isSelected = selectedCat == cat;
                        final color = AppColors.categoryColors[cat] ?? AppColors.textHint;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedCat = cat),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.only(right: 12),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? color : AppColors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? color : AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Text(CategoryKeys.emoji(cat), style: const TextStyle(fontSize: 16)),
                                const SizedBox(width: 6),
                                Text(
                                  CategoryKeys.label(cat),
                                  style: AppTextStyles.bodyBold.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                TextField(
                  controller: merchantController,
                  decoration: InputDecoration(
                    labelText: isIncome ? '입금처 (예: 월급)' : '가맹점명 (예: 스타벅스)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: '금액 (원)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: () async {
                      final merchant = merchantController.text.trim();
                      final amount = int.tryParse(amountController.text.trim()) ?? 0;
                      if (merchant.isEmpty || amount <= 0) return;

                      final expense = Expense(
                        id: '',
                        amount: amount,
                        category: isIncome ? CategoryKeys.income : selectedCat,
                        merchant: merchant,
                        isAuto: false,
                        spentAt: Timestamp.now(),
                      );

                      // 실제 수입/고정지출 값 조회
                      int income = 2500000;
                      int fixedExp = 500000;
                      try {
                        final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
                        income = userDoc.data()?['monthlyIncome'] as int? ?? 0;
                        final fixedSnap = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).collection(CollectionKeys.fixedExpenses).get();
                        fixedExp = fixedSnap.docs.fold<int>(0, (acc, doc) => acc + (doc.data()['amount'] as num).toInt());
                      } catch (_) {}

                      await BudgetService.addExpense(
                        uid: uid,
                        expense: expense,
                        monthlyIncome: income,
                        fixedExpenses: fixedExp,
                      );

                      if (context.mounted) Navigator.pop(context);
                    },
                    child: Text('추가하기', style: AppTextStyles.button),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        }
      );
    },
  ).whenComplete(() {
    merchantController.dispose();
    amountController.dispose();
  });
}
