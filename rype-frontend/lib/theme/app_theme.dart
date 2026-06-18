import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  static const lightBackground = Color(0xFFFFFFFF);
  static const lightCard = Color(0xFFFFFFFF);
  static const lightSurface = Color(0xFFF8FAFC);
  static const lightPrimary = Color(0xFF2563EB);
  static const lightSuccess = Color(0xFF16A34A);
  static const lightWarning = Color(0xFFF59E0B);
  static const lightError = Color(0xFFDC2626);

  static const darkBackground = Color(0xFF0F172A);
  static const darkCard = Color(0xFF1E293B);
  static const darkSurface = Color(0xFF334155);
  static const darkPrimary = Color(0xFF3B82F6);
  static const darkSuccess = Color(0xFF22C55E);
  static const darkWarning = Color(0xFFFBBF24);
  static const darkError = Color(0xFFEF4444);
}

class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  static const pagePadding = EdgeInsets.all(lg);
  static const cardPadding = EdgeInsets.all(lg);
}

class AppTextStyles {
  static TextTheme build(Color onSurface, Color muted) {
    return TextTheme(
      headlineLarge: TextStyle(
        color: onSurface,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      headlineMedium: TextStyle(
        color: onSurface,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleLarge: TextStyle(
        color: onSurface,
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        color: onSurface,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      titleSmall: TextStyle(
        color: muted,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(color: onSurface, fontSize: 16),
      bodyMedium: TextStyle(color: onSurface, fontSize: 14),
      bodySmall: TextStyle(color: muted, fontSize: 12),
      labelLarge: TextStyle(
        color: onSurface,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class AppTheme {
  static const lightBackground = AppColors.lightBackground;
  static const lightCard = AppColors.lightCard;
  static const lightSurface = AppColors.lightSurface;
  static const lightPrimary = AppColors.lightPrimary;
  static const lightSuccess = AppColors.lightSuccess;
  static const lightWarning = AppColors.lightWarning;
  static const lightError = AppColors.lightError;

  static const darkBackground = AppColors.darkBackground;
  static const darkCard = AppColors.darkCard;
  static const darkSurface = AppColors.darkSurface;
  static const darkPrimary = AppColors.darkPrimary;
  static const darkSuccess = AppColors.darkSuccess;
  static const darkWarning = AppColors.darkWarning;
  static const darkError = AppColors.darkError;

  static ThemeData light() {
    return _theme(
      brightness: Brightness.light,
      background: lightBackground,
      card: lightCard,
      surface: lightSurface,
      primary: lightPrimary,
      success: lightSuccess,
      warning: lightWarning,
      error: lightError,
      onSurface: const Color(0xFF0F172A),
      muted: const Color(0xFF64748B),
    );
  }

  static ThemeData dark() {
    return _theme(
      brightness: Brightness.dark,
      background: darkBackground,
      card: darkCard,
      surface: darkSurface,
      primary: darkPrimary,
      success: darkSuccess,
      warning: darkWarning,
      error: darkError,
      onSurface: const Color(0xFFF8FAFC),
      muted: const Color(0xFFCBD5E1),
    );
  }

  static ThemeData _theme({
    required Brightness brightness,
    required Color background,
    required Color card,
    required Color surface,
    required Color primary,
    required Color success,
    required Color warning,
    required Color error,
    required Color onSurface,
    required Color muted,
  }) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: Colors.white,
      secondary: success,
      onSecondary: Colors.white,
      error: error,
      onError: Colors.white,
      surface: card,
      onSurface: onSurface,
    );

    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: background,
      colorScheme: colorScheme,
      fontFamily: 'Roboto',
      extensions: [
        FinanceColors(
          card: card,
          page: background,
          pageSurface: surface,
          success: success,
          warning: warning,
          danger: error,
          muted: muted,
          border: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          chartA: primary,
          chartB: success,
          chartC: warning,
          chartD: isDark ? const Color(0xFFA78BFA) : const Color(0xFF7C3AED),
        ),
      ],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: background,
        foregroundColor: onSurface,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          systemNavigationBarColor: background,
          systemNavigationBarIconBrightness: isDark
              ? Brightness.light
              : Brightness.dark,
        ),
        titleTextStyle: TextStyle(
          color: onSurface,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: isDark ? 0 : 1,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: TextStyle(color: muted, fontSize: 14),
        prefixIconColor: muted,
        suffixIconColor: muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.35)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surface,
        selectedColor: primary.withValues(alpha: 0.12),
        labelStyle: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
        side: BorderSide(
          color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark
            ? const Color(0xFF020617)
            : const Color(0xFF0F172A),
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      dividerTheme: DividerThemeData(
        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
      ),
      textTheme: AppTextStyles.build(onSurface, muted),
    );
  }
}

@immutable
class FinanceColors extends ThemeExtension<FinanceColors> {
  const FinanceColors({
    required this.card,
    required this.page,
    required this.pageSurface,
    required this.success,
    required this.warning,
    required this.danger,
    required this.muted,
    required this.border,
    required this.chartA,
    required this.chartB,
    required this.chartC,
    required this.chartD,
  });

  final Color card;
  final Color page;
  final Color pageSurface;
  final Color success;
  final Color warning;
  final Color danger;
  final Color muted;
  final Color border;
  final Color chartA;
  final Color chartB;
  final Color chartC;
  final Color chartD;

  @override
  FinanceColors copyWith({
    Color? card,
    Color? page,
    Color? pageSurface,
    Color? success,
    Color? warning,
    Color? danger,
    Color? muted,
    Color? border,
    Color? chartA,
    Color? chartB,
    Color? chartC,
    Color? chartD,
  }) {
    return FinanceColors(
      card: card ?? this.card,
      page: page ?? this.page,
      pageSurface: pageSurface ?? this.pageSurface,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      muted: muted ?? this.muted,
      border: border ?? this.border,
      chartA: chartA ?? this.chartA,
      chartB: chartB ?? this.chartB,
      chartC: chartC ?? this.chartC,
      chartD: chartD ?? this.chartD,
    );
  }

  @override
  FinanceColors lerp(ThemeExtension<FinanceColors>? other, double t) {
    if (other is! FinanceColors) return this;
    return FinanceColors(
      card: Color.lerp(card, other.card, t)!,
      page: Color.lerp(page, other.page, t)!,
      pageSurface: Color.lerp(pageSurface, other.pageSurface, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      muted: Color.lerp(muted, other.muted, t)!,
      border: Color.lerp(border, other.border, t)!,
      chartA: Color.lerp(chartA, other.chartA, t)!,
      chartB: Color.lerp(chartB, other.chartB, t)!,
      chartC: Color.lerp(chartC, other.chartC, t)!,
      chartD: Color.lerp(chartD, other.chartD, t)!,
    );
  }
}

extension FinanceTheme on BuildContext {
  FinanceColors get finance => Theme.of(this).extension<FinanceColors>()!;
}
