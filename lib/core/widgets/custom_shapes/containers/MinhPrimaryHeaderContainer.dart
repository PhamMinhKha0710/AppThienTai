import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhCircularContainer.dart';
import 'package:cuutrobaolu/core/widgets/custom_shapes/curved_edges/Curved_Edges_Widget.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:flutter/cupertino.dart';

class MinhPrimaryHeaderContainer extends StatelessWidget {
  const MinhPrimaryHeaderContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MinhCurvedEdgeWidget(
      child: Container(
        width: double.infinity,
        color: MinhColors.primary,
        padding: EdgeInsets.all(0),
        child:Stack(
            children: [
              Positioned(
                top: -150,
                right: -250,
                child: MinhCircularContainer(
                  bordeRadius: 400,
                  backgroudColor: MinhColors.textWhite.withOpacity(0.1),
                ),
              ),
              Positioned(
                top: 100,
                right: -300,
                child: MinhCircularContainer(
                  bordeRadius: 400,
                  backgroudColor: MinhColors.textWhite.withOpacity(0.1),
                ),
              ),
              // Positioned.fill(
              //   child: child,
              // ),
              child,
            ],
          ),
        ),
    );
  }
}