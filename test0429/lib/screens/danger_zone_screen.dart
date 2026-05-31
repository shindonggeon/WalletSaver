import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../Part1Gps/monitoring.dart';
import '../services/notification_service.dart';
import '../services/ai_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class DangerZoneScreen extends StatefulWidget {
  const DangerZoneScreen({super.key});

  @override
  State<DangerZoneScreen> createState() => _DangerZoneScreenState();
}

class _DangerZoneScreenState extends State<DangerZoneScreen> {
  // ── Dummy Data ──────────────────────────────────────────
  bool isGpsEnabled = true;
  String selectedNagStrength = '적당히';
  bool isTesting = false;

  final List<Map<String, dynamic>> dangerZones = [
    {'name': '올리브영 강남본점', 'address': '서울 서초구 강남대로', 'isOn': true, 'emoji': '💄', 'category': 'shopping', 'lat': 37.498095, 'lng': 127.027610},
    {'name': '스타벅스 파미에스테이션', 'address': '서울 서초구 사평대로', 'isOn': true, 'emoji': '☕', 'category': 'cafe', 'lat': 37.504820, 'lng': 127.004944},
    {'name': '현대 프리미엄 아울렛', 'address': '경기 남양주시', 'isOn': false, 'emoji': '🛍️', 'category': 'shopping', 'lat': 37.618640, 'lng': 127.155823},
  ];
  // ────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (isGpsEnabled) {
      _toggleGps(true);
    }
  }

  void _toggleGps(bool val) {
    setState(() => isGpsEnabled = val);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      if (val) {
        Monitoring().startMonitoring(uid);
      } else {
        Monitoring().stopMonitoring(uid);
      }
    }
  }

  Future<void> _simulateGeofenceEvent(Map<String, dynamic> zone) async {
    setState(() => isTesting = true);
    
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw Exception('로그인이 필요합니다.');
      
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final characterType = userDoc.data()?['characterType'] as String? ?? 'ant';
      
      final aiService = AiService();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI가 진입 상황을 분석 중입니다...')));
      
      final aiMessage = await aiService.generateLocationWarning(
        placeName: zone['name'],
        category: zone['category'],
        remainingBudget: 3500, // 임시 잔액 
        todayBudget: 5000,
        budgetUsageRate: 0.9,
        monthlyGoal: '이번 달 목표 달성',
        characterType: characterType,
        naggingIntensity: selectedNagStrength == '강하게' ? 'high' : 'medium',
      );
      
      await NotificationService.showNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title: '🚨 위험 구역 [${zone['name']}] 감지!',
        body: aiMessage,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('테스트 실패: $e')));
    } finally {
      if (mounted) {
        setState(() => isTesting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeCount = dangerZones.where((z) => z['isOn'] == true).length;

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: AppColors.bgPage,
            elevation: 0,
            pinned: true,
            floating: true,
            title: Text('위험지역 감시망', style: AppTextStyles.pageTitle),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 상태 헤더 카드
                _buildStatusHeader(activeCount),
                const SizedBox(height: 20),

                // 실제 지도 뷰
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: FlutterMap(
                    options: MapOptions(
                      initialCenter: const LatLng(37.5015, 127.0163), // 강남과 파미에스테이션 사이
                      initialZoom: 13.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.test0429',
                      ),
                      MarkerLayer(
                        markers: dangerZones.map((zone) {
                          final bool isOn = zone['isOn'];
                          return Marker(
                            point: LatLng(zone['lat'], zone['lng']),
                            width: 50,
                            height: 50,
                            child: AnimatedScale(
                              scale: isOn ? 1.0 : 0.7,
                              duration: const Duration(milliseconds: 300),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isOn ? AppColors.stateDanger : AppColors.surfaceMuted,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: (isOn ? AppColors.stateDanger : AppColors.textHint).withValues(alpha: 0.3),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    )
                                  ],
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                alignment: Alignment.center,
                                child: Text(zone['emoji'] ?? '📍', style: const TextStyle(fontSize: 20)),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 위험 지역 목록
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('등록된 위험 지역', style: AppTextStyles.sectionHeader),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                      label: Text('추가', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...dangerZones.map((zone) => _buildZoneItem(zone)),
                const SizedBox(height: 24),

                // 잔소리 강도 선택
                Text('AI 잔소리 강도', style: AppTextStyles.sectionHeader),
                const SizedBox(height: 12),
                _buildNagStrengthSelector(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(int activeCount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isGpsEnabled
              ? [AppColors.stateDanger, const Color(0xFFB91C1C)]
              : [AppColors.textHint, AppColors.textMuted],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
          color: (isGpsEnabled ? AppColors.stateDanger : AppColors.textHint).withValues(alpha: 0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        )],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('감시 중인 지역', style: AppTextStyles.captionNormal.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Text('$activeCount곳', style: AppTextStyles.heroAmount.copyWith(fontSize: 28)),
              Text(isGpsEnabled ? '🟢 GPS 활성화' : '🔴 GPS 비활성화',
                  style: AppTextStyles.micro.copyWith(color: Colors.white70)),
            ],
          ),
          Column(
            children: [
              Text('GPS 감시', style: AppTextStyles.captionNormal.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              Transform.scale(
                scale: 0.85,
                child: Switch(
                  value: isGpsEnabled,
                  onChanged: _toggleGps,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.white.withValues(alpha: 0.4),
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildZoneItem(Map<String, dynamic> zone) {
    final bool isOn = zone['isOn'] as bool;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isOn ? AppColors.stateDanger.withValues(alpha: 0.3) : AppColors.border),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              width: 46, height: 46,
              decoration: BoxDecoration(
                color: isOn ? AppColors.stateDanger.withValues(alpha: 0.1) : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(zone['emoji'] ?? '📍', style: const TextStyle(fontSize: 22)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(zone['name'], style: AppTextStyles.bodyBold.copyWith(
                    color: isOn ? AppColors.textPrimary : AppColors.textHint,
                  )),
                  Text(zone['address'], style: AppTextStyles.captionNormal),
                  const SizedBox(height: 6),
                  if (isOn)
                    GestureDetector(
                      onTap: isTesting ? null : () => _simulateGeofenceEvent(zone),
                      child: Text('알림 테스트 시연 >', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
            Switch(
              value: isOn,
              onChanged: (val) => setState(() => zone['isOn'] = val),
              activeThumbColor: AppColors.stateDanger,
              activeTrackColor: AppColors.stateDanger.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNagStrengthSelector() {
    return Row(
      children: ['부드럽게', '적당히', '강하게'].map((str) {
        final isSelected = selectedNagStrength == str;
        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => selectedNagStrength = str),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(colors: [AppColors.stateDanger, Color(0xFFB91C1C)])
                    : null,
                color: isSelected ? null : AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: isSelected ? AppColors.stateDanger : AppColors.border),
                boxShadow: isSelected
                    ? [BoxShadow(color: AppColors.stateDanger.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 4))]
                    : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 6)],
              ),
              alignment: Alignment.center,
              child: Text(
                str,
                style: AppTextStyles.caption.copyWith(
                  color: isSelected ? Colors.white : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
