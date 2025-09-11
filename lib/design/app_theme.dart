import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const seed = Color(0xFF3879B8);
  static const radius = 16.0;

  static ThemeData _base(ThemeData base) {
    return base.copyWith(
      scaffoldBackgroundColor: base.colorScheme.surface,
      cardTheme: CardThemeData(
        color: base.colorScheme.surface,
        elevation: 0,
        margin: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
          side: BorderSide(color: base.colorScheme.outlineVariant),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: base.colorScheme.surface,
        foregroundColor: base.colorScheme.onSurface,
      ),
      dividerTheme: DividerThemeData(
        thickness: 1,
        space: 16,
        color: base.colorScheme.outlineVariant,
      ),
      listTileTheme: ListTileThemeData(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        iconColor: base.colorScheme.secondary,
      ),
      textTheme: base.textTheme.copyWith(
        headlineSmall:
            base.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w600),
        titleLarge:
            base.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        titleMedium:
            base.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        bodyMedium: base.textTheme.bodyMedium?.copyWith(height: 1.3),
      ),
    );
  }

  static ThemeData light() => _base(ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.light),
      ));

  static ThemeData dark() => _base(ThemeData(
        useMaterial3: true,
        colorScheme:
            ColorScheme.fromSeed(seedColor: seed, brightness: Brightness.dark),
      ));

  static ThemeData fromScheme(ColorScheme scheme) => _base(ThemeData(
        useMaterial3: true,
        colorScheme: scheme,
      ));
}
