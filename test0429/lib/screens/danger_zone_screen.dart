import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DangerZoneScreen extends StatefulWidget {
  const DangerZoneScreen({super.key});

  @override
  State<DangerZoneScreen> createState() => _DangerZoneScreenState();
}

class _DangerZoneScreenState extends State<DangerZoneScreen> {
  // ── Dummy Data ──────────────────────────────────────────
  bool isGpsEnabled = true;
  String selectedNagStrength = '적당히';

  final List<Map<String, dynamic>> dangerZones = [
    {'name': '올리브영 강남본점', 'address': '서울 서초구 강남대로', 'isOn': true, 'emoji': '💄'},
    {'name': '스타벅스 파미에스테이션', 'address': '서울 서초구 사평대로', 'isOn': true, 'emoji': '☕'},
    {'name': '현대 프리미엄 아울렛', 'address': '경기 남양주시', 'isOn': false, 'emoji': '🛍️'},
  ];
  // ────────────────────────────────────────────────────────

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

                // 지도 자리 표시
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.map_outlined, size: 48, color: AppColors.primary.withValues(alpha: 0.4)),
                      const SizedBox(height: 8),
                      Text('지도 연동 예정', style: AppTextStyles.body.copyWith(color: AppColors.primary.withValues(alpha: 0.6))),
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
                  onChanged: (val) => setState(() => isGpsEnabled = val),
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
