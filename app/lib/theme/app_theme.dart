import 'package:flutter/material.dart';
import '../models/deadline_entry.dart';

/// Palette dell'app.
///
/// Scelta di design: il testo resta sempre scuro e leggibile; il colore è
/// riservato allo stato della scadenza (verde a posto, giallo in scadenza,
/// rosso scaduto, grigio non impostata).
class AppColors {
  static const bg = Color(0xFFF6F5F2);
  static const card = Color(0xFFFFFFFF);
  static const ink = Color(0xFF1B1B19);
  static const inkSecondary = Color(0xFF63625D);
  static const inkMuted = Color(0xFF93918A);
  static const hairline = Color(0xFFE3E1DA);

  static const okTint = Color(0xFFE7F2DC);
  static const okStrong = Color(0xFFC3DFA2);
  static const soonTint = Color(0xFFFBEFD5);
  static const soonStrong = Color(0xFFF2D293);
  static const overdueTint = Color(0xFFFAE4E2);
  static const overdueStrong = Color(0xFFEFB6B0);
  static const unsetTint = Color(0xFFF1EFE9);
  static const unsetStrong = Color(0xFFDDDBD3);

  static const brand = Color(0xFFC96442);

  static Color tintFor(DeadlineStatus status) {
    switch (status) {
      case DeadlineStatus.ok:
        return okTint;
      case DeadlineStatus.soon:
        return soonTint;
      case DeadlineStatus.overdue:
        return overdueTint;
      case DeadlineStatus.unset:
        return unsetTint;
    }
  }

  static Color strongFor(DeadlineStatus status) {
    switch (status) {
      case DeadlineStatus.ok:
        return okStrong;
      case DeadlineStatus.soon:
        return soonStrong;
      case DeadlineStatus.overdue:
        return overdueStrong;
      case DeadlineStatus.unset:
        return unsetStrong;
    }
  }
}

ThemeData buildAppTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.brand,
      surface: AppColors.card,
      onSurface: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.bg,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      foregroundColor: AppColors.ink,
    ),
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    dividerColor: AppColors.hairline,
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: AppColors.brand),
      ),
    ),
  );
}
