import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';
import '../../constants/app_constants.dart';

class NicknameSetupScreen extends StatefulWidget {
  const NicknameSetupScreen({super.key});

  @override
  State<NicknameSetupScreen> createState() => _NicknameSetupScreenState();
}

class _NicknameSetupScreenState extends State<NicknameSetupScreen> {
  final _controller = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    final nickname = _controller.text.trim();
    if (nickname.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('닉네임을 입력해주세요.')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      setState(() => _isSaving = true);
      try {
        await FirebaseFirestore.instance
            .collection(CollectionKeys.users)
            .doc(uid)
            .set({'nickname': nickname}, SetOptions(merge: true));
      } catch (e) {
        // 무시하고 진행
      } finally {
        if (mounted) setState(() => _isSaving = false);
      }
    }

    if (mounted) {
      context.push('/onboarding/test');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.bgPage,
        elevation: 0,
        title: Text('기본 설정', style: AppTextStyles.bodyBold.copyWith(fontSize: 16)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                '만나서 반가워요!\n어떻게 불러드릴까요?',
                style: AppTextStyles.greetingTitle.copyWith(
                  color: AppColors.primary,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: '닉네임',
                  hintText: '예: 소리',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                maxLength: 10,
                onSubmitted: (_) => _next(),
              ),
              const Spacer(),
              SizedBox(
                height: 56,
                child: FilledButton(
                  onPressed: _isSaving ? null : _next,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text('다음으로', style: AppTextStyles.button.copyWith(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
