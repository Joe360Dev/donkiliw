import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/utils/size_config.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFCD853F); // Peru
  final BuildContext context;
  final Color seedColor;

  AppTheme({
    required this.context,
    required this.seedColor,
  });

  ThemeData _buildBaseTheme() {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: seedColor,
      ),
      textTheme: GoogleFonts.notoSansTextTheme().apply(
        fontFamily: 'NotoSans',
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultSize * .25),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        trackHeight: defaultSize * .5,
      ),
    );
  }

  ThemeData buildLightTheme() {
    return _buildBaseTheme();
  }

  ThemeData buildDarkTheme() {
    final baseTheme = _buildBaseTheme();
    final darkColorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    );

    return baseTheme.copyWith(
      colorScheme: darkColorScheme,
      textTheme: GoogleFonts.notoSansTextTheme(
        ThemeData.dark().textTheme,
      ),
      scaffoldBackgroundColor: darkColorScheme.surface,
      cardColor: darkColorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: darkColorScheme.surface,
        foregroundColor: darkColorScheme.onSurface,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: darkColorScheme.surface,
        selectedItemColor: darkColorScheme.primary,
        unselectedItemColor: darkColorScheme.onSurface.withAlpha(153),
      ),
      dialogTheme: DialogThemeData(backgroundColor: darkColorScheme.surface),
    );
  }
}
