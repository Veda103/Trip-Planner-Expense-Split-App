import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─── App-wide colour palette ────────────────────────────────────────
class AppColors {
  static const coral = Color(0xFFFF6B6B);
  static const coralDark = Color(0xFFEE5A5A);
  static const mint = Color(0xFF4ECDC4);
  static const mintLight = Color(0xFFE0FAF7);
  static const sunflower = Color(0xFFFFE66D);
  static const cream = Color(0xFFFFF9F0);
  static const peach = Color(0xFFFFD6A5);
  static const lavender = Color(0xFFCDB4DB);
  static const skyBlue = Color(0xFFA2D2FF);
  static const textDark = Color(0xFF2D3436);
  static const textMuted = Color(0xFF636E72);
  static const cardWhite = Color(0xFFFFFEFC);
  static const danger = Color(0xFFE17055);
  static const success = Color(0xFF00B894);
}

/// ─── Text styles using Google Fonts ─────────────────────────────────
class AppText {
  /// Cursive / handwriting for headings
  static TextStyle cursive(
          {double size = 24,
          Color color = AppColors.textDark,
          FontWeight weight = FontWeight.w700}) =>
      GoogleFonts.pacifico(fontSize: size, color: color, fontWeight: weight);

  /// Body font
  static TextStyle body(
          {double size = 14,
          Color color = AppColors.textDark,
          FontWeight weight = FontWeight.w400}) =>
      GoogleFonts.poppins(fontSize: size, color: color, fontWeight: weight);

  /// Logo widget
  static Widget appLogo({double size = 32}) => Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
      );

  /// Label / caption
  static TextStyle label(
          {double size = 12,
          Color color = AppColors.textMuted,
          FontWeight weight = FontWeight.w600}) =>
      GoogleFonts.poppins(fontSize: size, color: color, fontWeight: weight);
}

/// ─── Shared decoration helpers ──────────────────────────────────────
class AppDecor {
  static BoxDecoration get softCard => BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  static InputDecoration inputDecoration(String label, {IconData? icon}) =>
      InputDecoration(
        labelText: label,
        labelStyle: AppText.label(size: 13),
        prefixIcon: icon != null
            ? Icon(icon, color: AppColors.coral, size: 20)
            : null,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.peach.withOpacity(0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.peach.withOpacity(0.4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.coral, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  static ButtonStyle primaryButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.coral,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    textStyle: AppText.body(size: 15, weight: FontWeight.w600),
  );

  static ButtonStyle mintButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.mint,
    foregroundColor: Colors.white,
    elevation: 2,
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  static ButtonStyle dangerButton = ElevatedButton.styleFrom(
    backgroundColor: AppColors.danger,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
  );
}
