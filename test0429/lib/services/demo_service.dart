import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../Part1Gps/danger_zone.dart';

/// 캡스톤 경진대회 시연용 초기 데이터 삽입 서비스
class DemoService {
  DemoService._();

  static Future<void> seedDemoData(BuildContext context, String uid) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🌱 데모 데이터 초기화'),
        content: const Text(
          '기존 이번 달 지출·챌린지·위험 지역을 지우고\n'
          '시연용 초기 데이터를 넣습니다.\n\n'
          '계속하시겠어요?',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('초기화')),
        ],
      ),
    );
    if (confirmed != true) return;

    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('⏳ 데모 데이터 삽입 중...'), duration: Duration(seconds: 30)),
    );

    try {
      final db = FirebaseFirestore.instance;
      final userRef = db.collection(CollectionKeys.users).doc(uid);
      final now = DateTime.now();
      final year = now.year;
      final month = now.month;

      // ── 1. 유저 기본 정보 ─────────────────────────────────
      await userRef.set({
        'uid':              uid,
        'nickname':         '동건',
        'characterType':    'lion_shopping',
        'characterLevel':   1,
        'monthlyIncome':    2000000,
        'monthlyGoal':      300000,
        'age':              24,
        'naggingIntensity': 'normal',
        'level':            2,
        'exp':              15,
        'createdAt':        DateTime(year, month < 3 ? 1 : month - 2, 15),
      }, SetOptions(merge: true));

      // ── 2. 고정 지출 ─────────────────────────────────────
      final fixedRef = userRef.collection(CollectionKeys.fixedExpenses);
      for (final d in (await fixedRef.get()).docs) { await d.reference.delete(); }
      const fixedList = [
        {'name': '월세',     'amount': 500000},
        {'name': '통신비',   'amount': 55000},
        {'name': '넷플릭스', 'amount': 17000},
      ];
      for (final fe in fixedList) { await fixedRef.add(fe); }
      const totalFixed  = 500000 + 55000 + 17000; // 572,000
      const totalBudget = 2000000 - totalFixed;    // 1,428,000

      // ── 3. 이번 달 지출 내역 ─────────────────────────────
      final expRef = userRef.collection(CollectionKeys.expenses);
      final startOfMonth = DateTime(year, month, 1);
      for (final d in (await expRef
          .where('spentAt', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMonth))
          .get()).docs) {
        await d.reference.delete();
      }
      final today = now.day;
      // 총 ~287,000원 → 사용률 약 61% (노란 경고 테마)
      final expData = [
        {'merchant': '이마트',    'amount': 45000,  'category': 'food',              'day': 1,                       'hour': 19},
        {'merchant': '스타벅스',  'amount': 6500,   'category': 'cafe',              'day': 2,                       'hour': 9},
        {'merchant': '카카오택시','amount': 12000,  'category': 'transport',         'day': 3,                       'hour': 23},
        {'merchant': 'GS25',      'amount': 8200,   'category': 'convenience',       'day': 4,                       'hour': 14},
        {'merchant': '쿠팡',      'amount': 35000,  'category': 'shopping',          'day': 5,                       'hour': 22},
        {'merchant': '맥도날드',  'amount': 9500,   'category': 'food',              'day': 6,                       'hour': 13},
        {'merchant': '메가커피',  'amount': 4500,   'category': 'cafe',              'day': 7,                       'hour': 8},
        {'merchant': 'CGV',       'amount': 14000,  'category': 'leisure',           'day': 8,                       'hour': 18},
        {'merchant': '올리브영',  'amount': 22000,  'category': 'self_satisfaction', 'day': 9,                       'hour': 15},
        {'merchant': '롯데마트',  'amount': 38000,  'category': 'food',              'day': 10,                      'hour': 17},
        {'merchant': '버거킹',    'amount': 10500,  'category': 'food',              'day': (today - 2).clamp(1, 28),'hour': 12},
        {'merchant': '지하철',    'amount': 2500,   'category': 'transport',         'day': (today - 2).clamp(1, 28),'hour': 8},
        {'merchant': '다이소',    'amount': 15000,  'category': 'shopping',          'day': (today - 1).clamp(1, 28),'hour': 16},
        {'merchant': '이디야',    'amount': 4500,   'category': 'cafe',              'day': (today - 1).clamp(1, 28),'hour': 8},
        {'merchant': '무신사',    'amount': 59800,  'category': 'shopping',          'day': (today - 1).clamp(1, 28),'hour': 11},
      ];
      for (final e in expData) {
        await expRef.add({
          'amount':   e['amount'],
          'category': e['category'],
          'merchant': e['merchant'],
          'isAuto':   false,
          'spentAt':  Timestamp.fromDate(
              DateTime(year, month, e['day'] as int, e['hour'] as int)),
        });
      }

      // ── 4. 과거 3개월 예산 (바 차트용) ───────────────────
      final pastData = [
        {'offset': 3, 'spent': 1250000},
        {'offset': 2, 'spent': 980000},
        {'offset': 1, 'spent': 1380000},
      ];
      for (final p in pastData) {
        int m = month - (p['offset'] as int);
        int y = year;
        if (m <= 0) { m += 12; y -= 1; }
        final ym = '$y-${m.toString().padLeft(2, '0')}';
        final spent = p['spent'] as int;
        await userRef.collection(CollectionKeys.budgets).doc(ym).set({
          'totalBudget':     totalBudget,
          'totalSpent':      spent,
          'remainingBudget': totalBudget - spent,
          'todayBudget':     0,
          'updatedAt':       Timestamp.fromDate(DateTime(y, m, 28)),
        });
      }

      // ── 5. 이번 달 budget 문서 삭제 → 앱이 자동 재계산 ──
      await userRef.collection(CollectionKeys.budgets)
          .doc('$year-${month.toString().padLeft(2, '0')}')
          .delete();

      // ── 6. 챌린지 ────────────────────────────────────────
      final chalRef = userRef.collection(CollectionKeys.challenges);
      for (final d in (await chalRef.get()).docs) { await d.reference.delete(); }
      int pm = month - 1; int py = year;
      if (pm <= 0) { pm += 12; py -= 1; }
      final challenges = [
        {'title': '카페 한 달 3번만 가기',     'emoji': '☕', 'isActive': true,  'startedAt': Timestamp.fromDate(DateTime(year, month, 1))},
        {'title': '한 달 무지출 데이 5일 달성', 'emoji': '🎯', 'isActive': true,  'startedAt': Timestamp.fromDate(DateTime(year, month, 3))},
        {'title': '배달음식 끊기 2주',          'emoji': '🍱', 'isActive': false, 'startedAt': Timestamp.fromDate(DateTime(py, pm, 20))},
      ];
      for (final c in challenges) { await chalRef.add(c); }

      // ── 7. 위험 지역 ──────────────────────────────────────
      final zoneCol = db.collection(CollectionKeys.dangerZones);
      for (final d in (await zoneCol.where('uid', isEqualTo: uid).get()).docs) {
        await d.reference.delete();
      }
      final zones = [
        DangerZone(docId: zoneCol.doc().id, uid: uid, zoneName: '스타필드 코엑스',    zoneCategory: DangerZoneCategories.mall,          latitude: 37.5126, longitude: 127.0598),
        DangerZone(docId: zoneCol.doc().id, uid: uid, zoneName: '올리브영 강남점',    zoneCategory: DangerZoneCategories.dept,          latitude: 37.4979, longitude: 127.0276),
        DangerZone(docId: zoneCol.doc().id, uid: uid, zoneName: '홍대 걷고싶은거리',  zoneCategory: DangerZoneCategories.entertainment, latitude: 37.5563, longitude: 126.9228),
      ];
      for (final z in zones) { await zoneCol.doc(z.docId).set(z.toMap()); }

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ 완료! 잠시 후 홈 화면에 자동 반영됩니다.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
        ),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ 오류: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
