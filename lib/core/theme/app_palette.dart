import 'package:flutter/material.dart';

class AppPalette {
  // Music-themed color palette
  static const Color musicPurple = Color(0xFF8B5CF6);
  static const Color musicBlue = Color(0xFF3B82F6);
  static const Color musicPink = Color(0xFFEC4899);
  static const Color musicGreen = Color(0xFF10B981);
  static const Color musicOrange = Color(0xFFF59E0B);
  
  // Background colors
  static const Color backgroundDark = Color(0xFF0F0F0F);
  static const Color backgroundCard = Color(0xFF1A1A1A);
  static const Color backgroundAccent = Color(0xFF2A2A2A);
  
  // Contrast colors
  static const Color contrastLight = Color(0xFFFAFAFA);
  static const Color contrastMedium = Color(0xFFD1D5DB);
  static const Color contrastDark = Color(0xFF374151);
  
  // Status colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  
  // Gradient colors
  static const LinearGradient musicGradient = LinearGradient(
    colors: [musicPurple, musicBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient rewardGradient = LinearGradient(
    colors: [musicGreen, musicOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppColors extends ThemeExtension<AppColors> {
  final Color backgroundDark;
  final Color backgroundCard;
  final Color backgroundAccent;
  final Color contrastLight;
  final Color contrastMedium;
  final Color contrastDark;
  final Color musicPurple;
  final Color musicBlue;
  final Color musicPink;
  final Color musicGreen;
  final Color musicOrange;
  final Color success;
  final Color warning;
  final Color error;

  const AppColors({
    this.backgroundDark = AppPalette.backgroundDark,
    this.backgroundCard = AppPalette.backgroundCard,
    this.backgroundAccent = AppPalette.backgroundAccent,
    this.contrastLight = AppPalette.contrastLight,
    this.contrastMedium = AppPalette.contrastMedium,
    this.contrastDark = AppPalette.contrastDark,
    this.musicPurple = AppPalette.musicPurple,
    this.musicBlue = AppPalette.musicBlue,
    this.musicPink = AppPalette.musicPink,
    this.musicGreen = AppPalette.musicGreen,
    this.musicOrange = AppPalette.musicOrange,
    this.success = AppPalette.success,
    this.warning = AppPalette.warning,
    this.error = AppPalette.error,
  });

  @override
  AppColors copyWith({
    Color? backgroundDark,
    Color? backgroundCard,
    Color? backgroundAccent,
    Color? contrastLight,
    Color? contrastMedium,
    Color? contrastDark,
    Color? musicPurple,
    Color? musicBlue,
    Color? musicPink,
    Color? musicGreen,
    Color? musicOrange,
    Color? success,
    Color? warning,
    Color? error,
  }) {
    return AppColors(
      backgroundDark: backgroundDark ?? this.backgroundDark,
      backgroundCard: backgroundCard ?? this.backgroundCard,
      backgroundAccent: backgroundAccent ?? this.backgroundAccent,
      contrastLight: contrastLight ?? this.contrastLight,
      contrastMedium: contrastMedium ?? this.contrastMedium,
      contrastDark: contrastDark ?? this.contrastDark,
      musicPurple: musicPurple ?? this.musicPurple,
      musicBlue: musicBlue ?? this.musicBlue,
      musicPink: musicPink ?? this.musicPink,
      musicGreen: musicGreen ?? this.musicGreen,
      musicOrange: musicOrange ?? this.musicOrange,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) {
      return this;
    }
    return AppColors(
      backgroundDark: Color.lerp(backgroundDark, other.backgroundDark, t)!,
      backgroundCard: Color.lerp(backgroundCard, other.backgroundCard, t)!,
      backgroundAccent: Color.lerp(backgroundAccent, other.backgroundAccent, t)!,
      contrastLight: Color.lerp(contrastLight, other.contrastLight, t)!,
      contrastMedium: Color.lerp(contrastMedium, other.contrastMedium, t)!,
      contrastDark: Color.lerp(contrastDark, other.contrastDark, t)!,
      musicPurple: Color.lerp(musicPurple, other.musicPurple, t)!,
      musicBlue: Color.lerp(musicBlue, other.musicBlue, t)!,
      musicPink: Color.lerp(musicPink, other.musicPink, t)!,
      musicGreen: Color.lerp(musicGreen, other.musicGreen, t)!,
      musicOrange: Color.lerp(musicOrange, other.musicOrange, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
    );
  }
}

extension AppColorsExtension on BuildContext {
  AppColors get appColors => Theme.of(this).extension<AppColors>()!;
}