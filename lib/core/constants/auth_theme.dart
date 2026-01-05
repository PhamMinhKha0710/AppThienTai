import 'dart:ui';
import 'package:flutter/material.dart';

/// Auth Theme - Modern design tokens for authentication screens
class AuthTheme {
  AuthTheme._();

  // ==================== GRADIENTS ====================
  
  /// Primary gradient for background
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF0D9488), // Teal 600
      Color(0xFF0284C7), // Sky 600
      Color(0xFF6366F1), // Indigo 500
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Dark mode gradient
  static const LinearGradient backgroundGradientDark = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF134E4A), // Teal 900
      Color(0xFF0C4A6E), // Sky 900
      Color(0xFF312E81), // Indigo 900
    ],
    stops: [0.0, 0.5, 1.0],
  );

  /// Button gradient
  static const LinearGradient buttonGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF14B8A6), // Teal 500
      Color(0xFF0EA5E9), // Sky 500
    ],
  );

  /// Button gradient hover
  static const LinearGradient buttonGradientHover = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFF0D9488), // Teal 600
      Color(0xFF0284C7), // Sky 600
    ],
  );

  // ==================== GLASSMORPHISM ====================

  /// Glass card decoration
  static BoxDecoration glassCard({bool isDark = false}) => BoxDecoration(
    color: isDark 
        ? Colors.white.withOpacity(0.1) 
        : Colors.white.withOpacity(0.85),
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark 
          ? Colors.white.withOpacity(0.2) 
          : Colors.white.withOpacity(0.5),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );

  /// Glass input decoration
  static InputDecoration glassInputDecoration({
    required String labelText,
    required IconData prefixIcon,
    Widget? suffixIcon,
    bool isDark = false,
  }) => InputDecoration(
    labelText: labelText,
    labelStyle: TextStyle(
      color: isDark ? Colors.white70 : Colors.grey.shade600,
      fontWeight: FontWeight.w500,
    ),
    prefixIcon: Icon(
      prefixIcon,
      color: isDark ? Colors.white70 : const Color(0xFF0D9488),
    ),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: isDark 
        ? Colors.white.withOpacity(0.1) 
        : Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(
        color: isDark 
            ? Colors.white.withOpacity(0.2) 
            : Colors.grey.shade200,
        width: 1,
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFF14B8A6),
        width: 2,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444),
        width: 1,
      ),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(
        color: Color(0xFFEF4444),
        width: 2,
      ),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
  );

  // ==================== BUTTONS ====================

  /// Gradient button widget
  static Widget gradientButton({
    required VoidCallback onPressed,
    required String text,
    bool isLoading = false,
    double height = 56,
  }) => Container(
    width: double.infinity,
    height: height,
    decoration: BoxDecoration(
      gradient: buttonGradient,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF14B8A6).withOpacity(0.4),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      child: isLoading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
    ),
  );

  /// Social button
  static Widget socialButton({
    required VoidCallback onPressed,
    required String assetPath,
    bool isDark = false,
  }) => Container(
    decoration: BoxDecoration(
      color: isDark ? Colors.white.withOpacity(0.1) : Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark 
            ? Colors.white.withOpacity(0.2) 
            : Colors.grey.shade200,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: IconButton(
      onPressed: onPressed,
      padding: const EdgeInsets.all(16),
      icon: Image.asset(
        assetPath,
        width: 28,
        height: 28,
      ),
    ),
  );

  // ==================== TEXT STYLES ====================

  static TextStyle heroTitle({bool isDark = false}) => TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.white : Colors.white,
    letterSpacing: -0.5,
  );

  static TextStyle heroSubtitle({bool isDark = false}) => TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: isDark ? Colors.white70 : Colors.white.withOpacity(0.9),
    height: 1.5,
  );

  static TextStyle cardTitle({bool isDark = false}) => TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: isDark ? Colors.white : Colors.grey.shade800,
  );

  // ==================== DECORATIVE ELEMENTS ====================

  /// Floating blur circle for background
  static Widget floatingCircle({
    required double size,
    required Color color,
    required Alignment alignment,
  }) => Positioned.fill(
    child: Align(
      alignment: alignment,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.3),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
          child: Container(),
        ),
      ),
    ),
  );
}
