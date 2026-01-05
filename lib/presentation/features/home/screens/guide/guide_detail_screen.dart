import 'package:cuutrobaolu/core/widgets/appbar/MinhAppbar.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/presentation/features/home/models/guide_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

class GuideDetailScreen extends StatelessWidget {
  final GuideModel guide;

  const GuideDetailScreen({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MinhAppbar(
        title: Text(guide.category),
        showBackArrow: true,
      ),
      body: Markdown(
        data: guide.content,
        padding: const EdgeInsets.all(MinhSizes.defaultSpace),
        styleSheet: MarkdownStyleSheet(
          h1: Theme.of(context).textTheme.headlineMedium,
          h2: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
          listBullet: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
    );
  }
}
