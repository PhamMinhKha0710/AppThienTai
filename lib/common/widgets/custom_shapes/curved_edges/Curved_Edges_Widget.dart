import 'package:cuutrobaolu/common/widgets/custom_shapes/curved_edges/Curved_Edges.dart';
import 'package:flutter/material.dart';

class MinhCurvedEdgeWidget extends StatelessWidget {
  const MinhCurvedEdgeWidget({
    super.key, this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: MinhCustomCurvedEdges(),
      child: child,
    );
  }

}