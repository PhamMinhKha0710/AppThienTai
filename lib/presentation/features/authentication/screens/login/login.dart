import 'dart:ui';
import 'package:cuutrobaolu/core/constants/auth_theme.dart';
import 'package:cuutrobaolu/core/widgets/login_singup/MinhFromDriver.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/widget/LoginFooter.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/widget/LoginForm.dart';
import 'package:cuutrobaolu/presentation/features/authentication/screens/login/widget/LoginHeader.dart';
import 'package:cuutrobaolu/core/constants/sizes.dart';
import 'package:cuutrobaolu/core/constants/text_strings.dart';
import 'package:cuutrobaolu/core/utils/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = MinhHelperFunctions.isDarkMode(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: isDark 
              ? AuthTheme.backgroundGradientDark 
              : AuthTheme.backgroundGradient,
        ),
        child: Stack(
          children: [
            // Decorative floating circles
            Positioned(
              top: -100,
              right: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            ),
            Positioned(
              bottom: -150,
              left: -100,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.3,
              right: -50,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF14B8A6).withOpacity(0.2),
                ),
              ),
            ),

            // Main content
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),

                      // Hero Header
                      LoginHeader(isDark: isDark),

                      const SizedBox(height: 40),

                      // Glass Card with Form
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.all(28),
                            decoration: AuthTheme.glassCard(isDark: isDark),
                            child: Column(
                              children: [
                                // Card Title
                                Text(
                                  'Đăng nhập',
                                  style: AuthTheme.cardTitle(isDark: isDark),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Nhập thông tin để tiếp tục',
                                  style: TextStyle(
                                    color: isDark 
                                        ? Colors.white60 
                                        : Colors.grey.shade600,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 28),

                                // Form
                                LoginForm(isDark: isDark),

                                const SizedBox(height: 24),

                                // Divider
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: isDark 
                                            ? Colors.white24 
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16),
                                      child: Text(
                                        MinhTexts.orSignInWith.capitalize!,
                                        style: TextStyle(
                                          color: isDark 
                                              ? Colors.white60 
                                              : Colors.grey.shade500,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: isDark 
                                            ? Colors.white24 
                                            : Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // Social Login
                                LoginFooter(isDark: isDark),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
