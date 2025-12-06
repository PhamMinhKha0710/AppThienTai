import 'package:cuutrobaolu/core/widgets/custom_shapes/containers/MinhCircularContainer.dart';
import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';

class MinhChoiceChip extends StatelessWidget {
  const MinhChoiceChip({
    super.key,
    required this.text,
    required this.selected,
    this.onSelected,
  });

  final String text;
  final bool selected;
  final void Function(bool)? onSelected;


  @override
  Widget build(BuildContext context) {

    final isColor = MinhHelperFunctions.getColor(text) != null;

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: isColor  ? SizedBox() : Text(text),
        selected: selected,
        onSelected: onSelected,
        labelStyle: TextStyle(
          color: selected ? MinhColors.white : null,
        ),
        avatar: isColor
                        ? MinhCircularContainer(
                                width: 50,
                                height: 50,
                                backgroudColor: MinhHelperFunctions.getColor(text)!,
                              )
                        : null,
        labelPadding: isColor ? EdgeInsets.all(0) : null,
      
        padding: isColor ? EdgeInsets.all(0) : null,
        shape: isColor ? CircleBorder() : null,
        backgroundColor: isColor ? MinhHelperFunctions.getColor(text)! : null,
      
      ),
    );
  }
}
