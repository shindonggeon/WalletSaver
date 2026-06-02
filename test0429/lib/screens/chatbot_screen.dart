import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/budget_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _messages.add(ChatMessage(
      text: '안녕하세요! 저는 소리님의 금융 비서 AI입니다.\n"이번 달 소비패턴 어때?" 와 같이 무엇이든 물어보세요!',
      isUser: false,
      timestamp: DateTime.now(),
    ));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
      _isTyping = true;
    });
    _scrollToBottom();

    // AI 봇 응답 시뮬레이션
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    String response = '';

    // 실제 데이터 기반 응답을 위한 키워드 매칭 로직 (데모용)
    if (text.contains('소비') || text.contains('이번 달') || text.contains('어때') || text.contains('패턴')) {
      final user = context.read<User?>();
      if (user != null) {
        try {
          final snapshot = await BudgetService.budgetStream(user.uid).first;
          final expenses = await BudgetService.expenseStream(user.uid).first;
          
          if (snapshot != null) {
            final rate = snapshot.budgetUsageRate;
            final remaining = formatNumber(snapshot.remainingBudget);
            
            bool hasRecentLargeExpense = false;
            if (expenses.isNotEmpty) {
              final latest = expenses.first;
              if (latest.amount >= 300000 && DateTime.now().difference(latest.spentAt.toDate()).inHours < 24) {
                hasRecentLargeExpense = true;
              }
            }
            
            if (rate >= 100) {
              response = '이번 달 소비 패턴을 분석해 보았어요!\n\n현재 예산을 **초과**하여 사용하셨습니다. 남은 기간 동안 철저한 무지출 챌린지가 필요합니다 😱\n가계부를 확인해 어디서 많이 썼는지 점검해 보세요!';
            } else if (hasRecentLargeExpense) {
              response = '이번 달 소비 패턴을 분석해 보았어요!\n\n현재 예산의 **${rate.toStringAsFixed(1)}%** 를 사용하셨고 남은 예산은 **$remaining원**입니다. 전체 예산은 아직 여유가 있지만, 방금 큰 지출이 있었네요! 💸 남은 기간 동안은 소비 페이스를 다시 한 번 점검하는 것이 좋겠습니다.';
            } else if (rate >= 80) {
              response = '이번 달 소비 패턴을 분석해 보았어요!\n\n현재 예산의 **${rate.toStringAsFixed(1)}%** 를 사용하셨고, 남은 예산은 **$remaining원**입니다.\n지출 속도가 꽤 빠른 편이에요! 쇼핑과 배달 음식을 조금 줄여보는 건 어떨까요?';
            } else if (rate >= 50) {
              response = '이번 달 소비 패턴을 분석해 보았어요!\n\n현재 예산의 **${rate.toStringAsFixed(1)}%** 를 사용하셨네요. 남은 예산은 **$remaining원**입니다.\n페이스 조절이 잘 되고 있어요. 앞으로도 계획적인 소비를 이어가세요 😊';
            } else {
              response = '이번 달 소비 패턴을 분석해 보았어요!\n\n현재 예산의 **${rate.toStringAsFixed(1)}%** 밖에 사용하지 않으셨네요! 훌륭합니다 🎉\n지금처럼 낭비를 줄이고 꾸준히 저축을 이어가 보세요!';
            }
          } else {
            response = '이번 달 데이터가 아직 충분하지 않아요. 가계부에 지출 내역을 더 입력해 주시면 정확하게 분석해 드릴게요!';
          }
        } catch (e) {
          response = '앗, 지출 데이터를 불러오는 중 오류가 발생했어요. 잠시 후 다시 시도해 주세요.';
        }
      } else {
        response = '로그인 정보가 없어서 데이터를 분석할 수 없습니다.';
      }
    } else {
      response = '그 부분은 제가 좀 더 똑똑해지면 알려드릴게요! 대신 이번 달 예산이나 소비 패턴에 대해 물어봐 주시면 자세히 분석해 드릴 수 있어요.';
    }

    setState(() {
      _isTyping = false;
      _messages.add(ChatMessage(text: response, isUser: false, timestamp: DateTime.now()));
    });
    _scrollToBottom();
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!msg.isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: msg.isUser ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
                  bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
                ),
                boxShadow: [
                  if (!msg.isUser) BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))
                ],
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.body.copyWith(
                  color: msg.isUser ? Colors.white : AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (msg.isUser) const SizedBox(width: 32), // spacer for symmetry
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
        elevation: 0,
        title: Text('소리 AI 비서', style: AppTextStyles.pageTitle),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 16, bottom: 16),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _messages.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.psychology, color: Colors.white, size: 20),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: const BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                              ),
                            ),
                            child: const Text('AI가 분석 중입니다...', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                          ),
                        ],
                      ),
                    );
                  }
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.white,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: '메시지를 입력하세요',
                        hintStyle: const TextStyle(color: AppColors.textHint),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppColors.bgPage,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
