import '../constants/app_constants.dart';

/// 사용자가 설정한 위험 지역(쇼핑몰, 백화점 등) 정보를 담는 데이터 모델 클래스입니다.
class DangerZone {
  final String docId;        // Firestore 문서의 고유 ID (지오펜싱 식별자로도 사용됨)
  final String uid;          // ⭐️ 사용자 구분용 UID
  final String zoneName;     // 위험 지역의 이름 (예: "스타필드 코엑스")
  final String zoneCategory; // 카테고리 (app_constants.dart의 DangerZoneCategories 값 사용)
  final double latitude;     // 해당 장소의 위도
  final double longitude;    // 해당 장소의 경도
  final bool isEnabled;      // ⭐️ 새로 추가된 필드: 감시 활성화 여부

  // 생성자: 객체를 만들 때 반드시 모든 값을 넣도록 강제(required)합니다.
  DangerZone({
    required this.docId,
    required this.uid,
    required this.zoneName,
    required this.zoneCategory,
    required this.latitude,
    required this.longitude,
    this.isEnabled = true, // 기본값은 항상 켜짐(true)
  });

  /// 1. 앱 메모리에 있는 이 객체를 Firestore DB에 저장하기 위해 
  /// JSON(Map) 형태로 변환해 주는 함수입니다.
  Map<String, dynamic> toMap() {
    return {
      'docId': docId,
      'uid': uid,
      'zoneName': zoneName,

      'zoneCategory': zoneCategory,
      'latitude': latitude,
      'longitude': longitude,
      'isEnabled': isEnabled,
    };
  }

  /// 2. 반대로 Firestore DB나 지오펜스 하드웨어 이벤트에서 읽어온 JSON(Map) 데이터를 
  /// 다시 앱에서 쓸 수 있는 DangerZone 객체로 조립해 주는 팩토리 함수입니다.
  factory DangerZone.fromMap(Map<String, dynamic> map) {
    return DangerZone(
      docId: map['docId'] ?? '',
      uid: map['uid'] ?? '',
      zoneName: map['zoneName'] ?? '',
      // 값이 비어있을 경우 app_constants.dart에 정의된 'etc'(기타)를 기본값으로 사용
      zoneCategory: map['zoneCategory'] ?? DangerZoneCategories.etc,
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      isEnabled: map['isEnabled'] ?? true, // DB에 없으면 기본값 true
    );
  }
}
