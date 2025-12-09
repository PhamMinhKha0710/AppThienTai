import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:flutter/material.dart';

/// Suggestion button cho chatbot
class MinhChatbotSuggestion extends StatelessWidget {
  const MinhChatbotSuggestion({
    super.key,
    required this.text,
    required this.onTap,
  });

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: MinhSizes.spaceBtwItems),
        padding: EdgeInsets.all(MinhSizes.defaultSpace),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(MinhSizes.borderRadiusMd),
        ),
        child: Text(text),
      ),
    );
  }
}

