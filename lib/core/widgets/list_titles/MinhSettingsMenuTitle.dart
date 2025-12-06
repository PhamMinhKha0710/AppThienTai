import 'package:cuutrobaolu/core/constants/colors.dart';
import 'package:flutter/material.dart';

class MinhSettingsMenuTitle extends StatelessWidget {
  const MinhSettingsMenuTitle({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title, subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListTile(
        leading: Icon(icon , size: 28, color: MinhColors.primary,),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium,),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.labelMedium,),
        trailing: trailing,
        onTap: onTap,
        
      ),
    );
  }
}
