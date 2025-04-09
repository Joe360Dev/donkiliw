import 'package:flutter/material.dart';
import 'package:hymns/utils/app_theme.dart';
import 'package:hymns/utils/language_enum.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsProvider with ChangeNotifier {
  static const String _languageKey = 'language';
  static const String _themeModeKey = 'themeMode';
  static const String _fontSizeKey = 'fontSize';
  static const String _themeColorKey = 'themeColor';
  static const String repeatRefrainKey = 'repeatRefrain';
  static const String separatorBetweenSectionsKey = 'separatorBetweenSections';

  Language _language = Language.french;
  Language get language => _language;

  String get languageCode {
    switch (_language) {
      case Language.french:
        return 'fr';
      case Language.bambara:
        return 'bm';
      case Language.english:
        return 'en';
    }
  }

  String get languageCountryCode {
    switch (_language) {
      case Language.french:
        return 'FR';
      case Language.bambara:
        return 'ML';
      case Language.english:
        return 'US';
    }
  }

  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  double _fontSize = 16.0;
  double get fontSize => _fontSize;

  Color _themeColor = AppTheme.primaryColor;
  Color get themeColor => _themeColor;

  bool _repeatRefrain = true;
  bool get repeatRefrain => _repeatRefrain;

  bool _separatorBetweenSections = false;
  bool get separatorBetweenSections => _separatorBetweenSections;

  SettingsProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();

    final languageIndex = prefs.getInt(_languageKey) ?? Language.french.index;
    _language = Language.values[languageIndex];

    final themeModeIndex =
        prefs.getInt(_themeModeKey) ?? ThemeMode.system.index;
    _themeMode = ThemeMode.values[themeModeIndex];

    _fontSize = prefs.getDouble(_fontSizeKey) ?? 14.0;

    final themeColorValue =
        prefs.getInt(_themeColorKey) ?? AppTheme.primaryColor.value;
    _themeColor = Color(themeColorValue);

    _repeatRefrain = prefs.getBool(repeatRefrainKey) ?? true;
    _separatorBetweenSections =
        prefs.getBool(separatorBetweenSectionsKey) ?? false;

    notifyListeners();
  }

  Future<void> setLanguage(Language value) async {
    _language = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_languageKey, _language.index);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }

  Future<void> setFontSize(double size) async {
    _fontSize = size;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, size);
    notifyListeners();
  }

  Future<void> setThemeColor(Color color) async {
    _themeColor = color;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeColorKey, color.value);
    notifyListeners();
  }

  Future<void> setRepeatRefrain(bool value) async {
    _repeatRefrain = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(repeatRefrainKey, value);
    notifyListeners();
  }

  Future<void> setSeparatorBetweenSections(bool value) async {
    _separatorBetweenSections = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(separatorBetweenSectionsKey, value);
    notifyListeners();
  }
}
