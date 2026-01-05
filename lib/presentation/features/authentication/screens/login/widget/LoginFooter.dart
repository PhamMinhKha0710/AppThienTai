import 'package:cuutrobaolu/core/constants/auth_theme.dart';
import 'package:cuutrobaolu/presentation/features/authentication/controllers/login/login_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:cuutrobaolu/core/constants/image_strings.dart';

class LoginFooter extends StatelessWidget {
  const LoginFooter({
    super.key,
    this.isDark = false,
  });

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());

    return Column(
      children: [
        // Social Login Buttons
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            // Google Button
            _SocialLoginButton(
              onPressed: () => controller.googleSignIn(),
              assetPath: MinhImages.google,
              label: 'Google',
              isDark: isDark,
            ),

            // Facebook Button
            _SocialLoginButton(
              onPressed: () {
                // TODO: Implement Facebook login
              },
              assetPath: MinhImages.facebook,
              label: 'Facebook',
              isDark: isDark,
            ),
          ],
        ),
      ],
    );
  }
}

class _SocialLoginButton extends StatefulWidget {
  const _SocialLoginButton({
    required this.onPressed,
    required this.assetPath,
    required this.label,
    this.isDark = false,
  });

  final VoidCallback onPressed;
  final String assetPath;
  final String label;
  final bool isDark;

  @override
  State<_SocialLoginButton> createState() => _SocialLoginButtonState();
}

class _SocialLoginButtonState extends State<_SocialLoginButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            color: widget.isDark 
                ? (_isHovered 
                    ? Colors.white.withOpacity(0.15) 
                    : Colors.white.withOpacity(0.1))
                : (_isHovered 
                    ? Colors.grey.shade100 
                    : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isDark 
                  ? Colors.white.withOpacity(0.2) 
                  : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                widget.assetPath,
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
                style: TextStyle(
                  color: widget.isDark ? Colors.white : Colors.grey.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
