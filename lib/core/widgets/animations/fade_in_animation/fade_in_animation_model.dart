class FadeInAnimationModel {
  final Duration delay;
  final Duration duration;
  final double startPosition;
  final double endPosition;
  final double? topBefore;
  final double? topAfter;
  final double? bottomBefore;
  final double? bottomAfter;
  final double? leftBefore;
  final double? leftAfter;
  final double? rightBefore;
  final double? rightAfter;

  const FadeInAnimationModel({
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 800),
    this.startPosition = 0.0,
    this.endPosition = 0.0,
    this.topBefore,
    this.topAfter,
    this.bottomBefore,
    this.bottomAfter,
    this.leftBefore,
    this.leftAfter,
    this.rightBefore,
    this.rightAfter,
  });
}
