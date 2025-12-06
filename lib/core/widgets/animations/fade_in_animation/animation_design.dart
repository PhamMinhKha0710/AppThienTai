import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'fade_in_animation_controller.dart';
import 'fade_in_animation_model.dart';

class MinhFadeInAnimation extends StatelessWidget {
  final Widget child;
  final FadeInAnimationModel animate;
  final bool isTwoWayAnimation;
  final int durationInMs;

  const MinhFadeInAnimation({
    super.key,
    required this.child,
    required this.animate,
    this.isTwoWayAnimation = false,
    this.durationInMs = 1200,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FadeInAnimationController>();
    return Obx(() {
      final duration = Duration(milliseconds: durationInMs);
      return AnimatedPositioned(
        duration: duration,
        top: controller.animate.value 
            ? (animate.topAfter ?? animate.endPosition) 
            : (animate.topBefore ?? animate.startPosition),
        bottom: controller.animate.value 
            ? (animate.bottomAfter ?? animate.endPosition) 
            : (animate.bottomBefore ?? animate.startPosition),
        left: controller.animate.value 
            ? (animate.leftAfter ?? animate.endPosition) 
            : (animate.leftBefore ?? animate.startPosition),
        right: controller.animate.value 
            ? (animate.rightAfter ?? animate.endPosition) 
            : (animate.rightBefore ?? animate.startPosition),
        child: AnimatedOpacity(
          duration: duration,
          opacity: controller.animate.value ? 1 : 0,
          child: child,
        ),
      );
    });
  }
}

class MinhAnimatePosition extends FadeInAnimationModel {
  final double? bottomAfter;
  final double? bottomBefore;
  final double? leftBefore;
  final double? leftAfter;
  final double? topAfter;
  final double? topBefore;
  final double? rightAfter;
  final double? rightBefore;

  const MinhAnimatePosition({
    super.delay,
    super.duration,
    super.startPosition,
    super.endPosition,
    this.bottomAfter,
    this.bottomBefore,
    this.leftBefore,
    this.leftAfter,
    this.topAfter,
    this.topBefore,
    this.rightAfter,
    this.rightBefore,
  }) : super(
          topBefore: topBefore,
          topAfter: topAfter,
          bottomBefore: bottomBefore,
          bottomAfter: bottomAfter,
          leftBefore: leftBefore,
          leftAfter: leftAfter,
          rightBefore: rightBefore,
          rightAfter: rightAfter,
        );
}
