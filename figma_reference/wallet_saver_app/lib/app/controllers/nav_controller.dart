import 'package:get/get.dart';

/// 하단 내비게이션 탭 인덱스 컨트롤러
class NavController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void changeTo(int index) {
    if (index != currentIndex.value) {
      currentIndex.value = index;
    }
  }
}
