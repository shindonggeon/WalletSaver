import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';

class FinanceSetupScreen extends StatefulWidget {
  const FinanceSetupScreen({super.key});

  @override
  State<FinanceSetupScreen> createState() => _FinanceSetupScreenState();
}

class _FinanceSetupScreenState extends State<FinanceSetupScreen> {
  static const int totalIncome = 2500000;

  final List<Map<String, dynamic>> fixedExpenses = [
    {'name': '월세', 'amount': 500000},
    {'name': '통신비', 'amount': 60000},
    {'name': '구독료', 'amount': 15000},
  ];

  int get totalFixed => fixedExpenses.fold(0, (s, e) => s + (e['amount'] as int));
  int get available => totalIncome - totalFixed;

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
                  Text('월 평균 수입은\n얼마인가요?', style: AppTextStyles.greetingTitle.copyWith(fontSize: 22, height: 1.5)),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: const InputDecoration(hintText: '예: 2,500,000', suffixText: '원'),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('고정 지출', style: AppTextStyles.sectionHeader),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                        label: Text('추가', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...fixedExpenses.map((e) => _ExpenseItem(name: e['name'], amount: e['amount'])),
                ],
              ),
            ),
          ),
          // 하단: 예산 표시 + 다음 버튼
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), offset: const Offset(0, -4), blurRadius: 12)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('사용 가능 예산', style: AppTextStyles.bodyBold.copyWith(color: AppColors.textMuted)),
                    Text(
                      '${formatNumber(available)}원',
                      style: AppTextStyles.cardAmount.copyWith(color: AppColors.primary, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.push('/onboarding/challenge-setup'),
                    child: const Text('다음으로'),
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
  const _ExpenseItem({required this.name, required this.amount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 6)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(name, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
            Text('${formatNumber(amount)}원', style: AppTextStyles.bodyBold),
          ],
        ),
      ),
    );
  }
}
