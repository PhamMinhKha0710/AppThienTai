import 'package:get/get.dart';

class FadeInAnimationController extends GetxController {
  final RxBool animate = false.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void animationIn() {
    Future.delayed(const Duration(milliseconds: 500), () {
      animate.value = true;
    });
  }

  void startAnimation() {
    animationIn();
  }
}
