import 'package:cuutrobaolu/core/constants/auth_theme.dart';
import 'package:cuutrobaolu/core/constants/image_strings.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:flutter/material.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({
    super.key,
    required this.isDark,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated Logo with glow effect
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.1),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: Hero(
              tag: 'app_logo',
              child: Image(
                height: 100,
                width: 100,
                image: AssetImage(
                  isDark ? MinhImages.lightAppLogo : MinhImages.darkAppLogo,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 28),

        // Animated Title
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Text(
            MinhTexts.loginTitle,
            style: AuthTheme.heroTitle(isDark: isDark),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: 12),

        // Animated Subtitle
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              MinhTexts.loginSubTitle,
              style: AuthTheme.heroSubtitle(isDark: isDark),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}
