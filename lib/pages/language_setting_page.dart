import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/providers/settings_provider.dart';
import 'package:hymns/utils/language_enum.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:provider/provider.dart';

class LanguageSettingsPage extends StatefulWidget {
  const LanguageSettingsPage({super.key});
  static const String routeName = '/settings-language';

  @override
  State<LanguageSettingsPage> createState() => _LanguageSettingsPageState();
}

class _LanguageSettingsPageState extends State<LanguageSettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = Provider.of<SettingsProvider>(context);
    Language language = settings.language;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: Platform.isIOS,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        title: Text(
          l10n.languageLabel,
          style: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        children: [
          CheckboxListTile(
            value: language == Language.french,
            onChanged: (value) {
              setState(() {
                language = value == true ? Language.french : language;
                settings.setLanguage(language);
              });
            },
            title: Text('Français'),
            checkColor: colorScheme.primary,
            fillColor: WidgetStatePropertyAll(
              Colors.transparent,
            ),
            side: BorderSide(
              color: Colors.transparent,
            ),
          ),
          CheckboxListTile(
            enabled: false,
            value: language == Language.bambara,
            onChanged: (value) {
              setState(() {
                language = value == true ? Language.bambara : language;
                settings.setLanguage(language);
              });
            },
            checkColor: colorScheme.primary,
            fillColor: WidgetStatePropertyAll(
              Colors.transparent,
            ),
            side: BorderSide(
              color: Colors.transparent,
            ),
            title: Text('Bamanakan'),
          ),
          CheckboxListTile(
            value: language == Language.english,
            onChanged: (value) {
              setState(() {
                language = value == true ? Language.english : language;
                settings.setLanguage(language);
              });
            },
            checkColor: colorScheme.primary,
            fillColor: WidgetStatePropertyAll(
              Colors.transparent,
            ),
            side: BorderSide(
              color: Colors.transparent,
            ),
            title: Text('English'),
          ),
        ],
      ),
    );
  }
}
