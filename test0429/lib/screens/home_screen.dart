import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/character_card.dart';
import '../widgets/budget_card.dart';
import '../widgets/challenge_card.dart';
import '../widgets/expense_bottom_sheet.dart';
import 'chatbot_screen.dart';
import '../theme/app_theme.dart';
import '../services/budget_service.dart';
import '../services/user_service.dart';
import '../models/budget.dart';
import '../models/expense.dart';
import '../constants/app_constants.dart';
import '../models/challenge.dart';
import '../services/challenge_service.dart';

// Number format helper (간단한 구현)
String formatNumber(int n) =>
    n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = false;
  String? _characterType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      final user = context.watch<User?>();
      if (user != null) {
        _ensureBudgetExists(user.uid);
        _isInit = true;
      }
    }
  }

  Future<void> _ensureBudgetExists(String uid) async {
    try {
      final now = DateTime.now();
      final yearMonth = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      final budgetRef = FirebaseFirestore.instance
          .collection(CollectionKeys.users)
          .doc(uid)
          .collection(CollectionKeys.budgets)
          .doc(yearMonth);
      
      final doc = await budgetRef.get();
      
      final userDoc = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).get();
      if (mounted) {
        setState(() {
          _characterType = userDoc.data()?['characterType'] as String?;
        });
      }

      if (!doc.exists) {
        final monthlyIncome = (userDoc.data()?['monthlyIncome'] as num?)?.toInt() ?? 0;
        
        int fixedExpenses = 0;
        final fixedSnap = await FirebaseFirestore.instance.collection(CollectionKeys.users).doc(uid).collection(CollectionKeys.fixedExpenses).get();
        for (var fDoc in fixedSnap.docs) {
          fixedExpenses += (fDoc.data()['amount'] as num).toInt();
        }
        
        await BudgetService.recalculateAndSave(
          uid: uid,
          monthlyIncome: monthlyIncome,
          fixedExpenses: fixedExpenses,
        );
      }
    } catch (e) {
      print('Error ensuring budget exists: $e');
    }
  }

  void _runDemo(BuildContext context, String uid) async {
    // 1. 시스템 감지 스낵바 (하단)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('🛰️ 시스템: 위험 지역(스타벅스 강남점) 진입을 감지했습니다. AI 분석 중...'),
        duration: Duration(seconds: 2),
      ),
    );

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // 2. 푸시 알림 (상단 플로팅 스낵바)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).size.height - 180, // 상단에 띄우기 위한 트릭
          left: 16,
          right: 16,
        ),
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.stateDanger.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: const Icon(Icons.location_on, color: AppColors.stateDanger),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StreamBuilder<Budget?>(
                stream: BudgetService.budgetStream(uid),
                builder: (context, snapshot) {
                  final budget = snapshot.data;
                  final todayBudget = budget?.todayBudget ?? 0;
                  final remainingStr = formatNumber(todayBudget);
                  
                  String advice = '오늘 하루 쓸 수 있는 돈이 $remainingStr원입니다! 여기서 커피를 사면 오늘 하루 식비가 확 줄어들어요. 커피 대신 물을 마시는 건 어떨까요?';
                  if (todayBudget < 10000) {
                    advice = '오늘 쓸 수 있는 돈이 $remainingStr원밖에 남지 않았습니다! 이번 지출은 정말 필요한 것인지 다시 한 번 고민해 보세요.';
                  }

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('[소리 AI] 🚨 경고: 스타벅스 강남점', style: AppTextStyles.bodyBold.copyWith(color: AppColors.stateDanger)),
                      const SizedBox(height: 4),
                      Text(advice, style: AppTextStyles.captionNormal.copyWith(color: AppColors.textPrimary)),
                    ],
                  );
                }
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final uid = user.uid;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: StreamBuilder<Budget?>(
        stream: BudgetService.budgetStream(uid),
        builder: (context, budgetSnap) {
          final budget = budgetSnap.data;
          final budgetUsageRate = (budget?.budgetUsageRate ?? 0) / 100.0;
          final theme = AppTheme.getBudgetTheme(budgetUsageRate);

          return StreamBuilder<List<Expense>>(
            stream: BudgetService.expenseStream(uid),
            builder: (context, expenseSnap) {
              final expenses = expenseSnap.data ?? [];
              final recentTransactions = expenses.take(3).toList();

              String naggingText = '';
              bool hasRecentLargeExpense = false;
              if (recentTransactions.isNotEmpty) {
                final latest = recentTransactions.first;
                if (latest.amount >= 300000 && DateTime.now().difference(latest.spentAt.toDate()).inHours < 12) {
                  hasRecentLargeExpense = true;
                }
              }

              if (budgetUsageRate >= 1.0) {
                naggingText = '"예산이 초과되었습니다! 이제 지갑을 닫을 시간이에요."';
              } else if (hasRecentLargeExpense) {
                naggingText = '"방금 큰 지출이 있었네요! 💸 남은 예산을 고려해 당분간 꽉 조여 매야 합니다."';
              } else if (budgetUsageRate >= 0.8) {
                naggingText = '"예산이 20%밖에 안 남았어요! 당분간은 무지출 챌린지 어때요?"';
              } else if (budgetUsageRate >= 0.5) {
                naggingText = '"예산을 절반 이상 사용했어요! 조금만 더 아껴볼까요?"';
              } else {
                naggingText = '"아주 잘하고 있어요! 지금처럼만 계획적으로 사용합시다."';
              }

              return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                stream: UserService.userStream(uid),
                builder: (context, userDocSnap) {
                  final nickname = userDocSnap.data?.data()?['nickname'] as String? ?? '소리';

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_todayLabel(), style: AppTextStyles.captionNormal),
                                  Text('안녕하세요, $nickname님 👋', style: AppTextStyles.greetingTitle),
                                ],
                              ),
                              Row(
                                children: [
                                  _IconBtn(icon: Icons.auto_fix_high, onTap: () => _runDemo(context, uid)), // 라이브 시연용 데모 버튼
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _NaggingBanner(text: naggingText, themeColor: theme.primary),
                        const SizedBox(height: 16),

                        CharacterCard(
                          budgetUsageRate: budgetUsageRate,
                          characterType: _characterType,
                        ),
                        const SizedBox(height: 16),

                        BudgetCard(
                          todayBudget: budget?.todayBudget ?? 0,
                          monthlyBudget: budget?.totalBudget ?? 2500000,
                          monthlyExpense: budget?.totalSpent ?? 0,
                          monthlyRemaining: budget?.remainingBudget ?? 0,
                          budgetUsageRate: budgetUsageRate,
                        ),
                        const SizedBox(height: 16),

                        StreamBuilder<List<Challenge>>(
                          stream: ChallengeService.activeChallengesStream(FirebaseAuth.instance.currentUser?.uid ?? ''),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const SizedBox(height: 80, child: Center(child: CircularProgressIndicator()));
                            }
                            final challenges = snapshot.data ?? [];
                            if (challenges.isEmpty) {
                              return Container(
                                padding: const EdgeInsets.symmetric(vertical: 24),
                                decoration: BoxDecoration(
                                  color: AppColors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: Text('진행 중인 목표가 없습니다.', style: TextStyle(color: AppColors.textHint)),
                                ),
                              );
                            }
                            
                            // 진행 중인 첫 번째 챌린지를 표시하거나 리스트로 보여줍니다.
                            // 일단 가장 먼저 시작한 챌린지 1개만 강조해서 표시
                            final topChallenge = challenges.first;
                            return ChallengeCard(
                              challengeName: '${topChallenge.emoji} ${topChallenge.title}',
                              progressText: '진행 중',
                              isAchieving: true,
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        Text('최근 지출', style: AppTextStyles.sectionHeader),
                        const SizedBox(height: 12),
                        if (recentTransactions.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 20),
                            child: Center(child: Text('이번 달 지출 내역이 없습니다.', style: TextStyle(color: AppColors.textHint))),
                          )
                        else
                          ...recentTransactions.map((tx) => _TransactionItem(tx: tx)),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            showAddExpenseBottomSheet(context, uid);
                          },
                          child: _AddExpenseButton(primary: theme.primary),
                        ),
                      ]),
                    ),
                  ),
                ],
              );
            }
          );
        }
      );
    }
  ),
  floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatbotScreen()),
          );
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.chat_bubble_rounded, color: Colors.white),
      ),
    );
  }

  String _todayLabel() {
    final now = DateTime.now();
    const days = ['월', '화', '수', '목', '금', '토', '일'];
    final day = days[now.weekday - 1];
    return '${now.year}년 ${now.month}월 ${now.day}일 $day요일';
  }
}

class _NaggingBanner extends StatelessWidget {
  final String text;
  final Color themeColor;
  const _NaggingBanner({required this.text, required this.themeColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: themeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: themeColor.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(Icons.chat_bubble_outline_rounded, color: themeColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.body.copyWith(color: themeColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Icon(icon, size: 20, color: AppColors.textHint),
      ),
    );
  }
}

class _TransactionItem extends StatelessWidget {
  final Expense tx;
  const _TransactionItem({required this.tx});

  @override
  Widget build(BuildContext context) {
    final catColor = AppColors.categoryColors[tx.category] ?? AppColors.textHint;
    final catLabel = CategoryKeys.label(tx.category);
    final date = tx.spentAt.toDate();
    final timeStr = '${date.hour.toString().padLeft(2,'0')}:${date.minute.toString().padLeft(2,'0')}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: catColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(CategoryKeys.emoji(tx.category), style: const TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.merchant, style: AppTextStyles.bodyBold.copyWith(color: AppColors.textPrimary)),
                Text('$catLabel · $timeStr', style: AppTextStyles.captionNormal),
              ],
            ),
          ),
          Text(
            '-${formatNumber(tx.amount)}원',
            style: AppTextStyles.bodyBold.copyWith(
              color: AppColors.expense,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddExpenseButton extends StatelessWidget {
  final Color primary;
  const _AddExpenseButton({required this.primary});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primary, AppColors.primaryLight],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: primary.withValues(alpha: 0.45), blurRadius: 20, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.add_rounded, color: Colors.white, size: 22),
          const SizedBox(width: 8),
          Text('지출 추가하기', style: AppTextStyles.button),
        ],
      ),
    );
  }
}
