import 'dart:io';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/providers/settings_provider.dart';
import 'package:hymns/utils/app_theme.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/circular_color_choice_chip.dart';
import 'package:provider/provider.dart';

class AppearenceSettingPage extends StatelessWidget {
  const AppearenceSettingPage({super.key});
  static const String routeName = '/settings-apparence';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final settings = Provider.of<SettingsProvider>(context);

    // theme colors
    List<MaterialColor> themeColors = [
      MaterialColor(AppTheme.primaryColor.value, {}),
      ...Colors.primaries,
    ];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: Platform.isIOS,
        titleSpacing: 0,
        automaticallyImplyLeading: true,
        title: Text(
          l10n.appearancePageTitle,
          style: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          vertical: defaultSize * .5,
          horizontal: defaultSize * .5,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text(
                l10n.themeMode,
                style: textTheme.titleMedium!.copyWith(
                  fontSize: defaultSize * .9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.only(
                  top: defaultSize * .7,
                  left: defaultSize * .5,
                  right: defaultSize * .5,
                ),
                child: SegmentedButton<ThemeMode>(
                  segments: <ButtonSegment<ThemeMode>>[
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.light,
                      label: Text(
                        l10n.lightMode,
                        style: textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.dark,
                      label: Text(
                        l10n.darkMode,
                        style: textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Icon(Icons.dark_mode),
                    ),
                    ButtonSegment<ThemeMode>(
                      value: ThemeMode.system,
                      label: Text(
                        l10n.systemMode,
                        style: textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      icon: Icon(Icons.settings),
                    ),
                  ],
                  selected: <ThemeMode>{settings.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    settings.setThemeMode(newSelection.first);
                  },
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            Divider(height: defaultSize),
            ListTile(
              title: Text(
                l10n.themeColor,
                style: textTheme.titleMedium!.copyWith(
                  fontSize: defaultSize * .9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.only(
                  top: defaultSize * .7,
                  left: defaultSize * .25,
                  right: defaultSize * .25,
                ),
                child: Wrap(
                  runSpacing: 5.0,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: themeColors.map(
                    (color) {
                      return CircularColorChoiceChip(
                        onSelected: (p0) {
                          settings.setThemeColor(color);
                        },
                        isSelected: settings.themeColor.value == color.value,
                        color: color,
                      );
                    },
                  ).toList(),
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SizedBox(height: defaultSize * .6),
            ListTile(
              title: Text(
                l10n.fontSize,
                style: textTheme.titleMedium!.copyWith(
                  fontSize: defaultSize * .9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0,
                ),
              ),
              subtitle: Container(
                padding: EdgeInsets.only(
                  top: defaultSize * .7,
                  left: defaultSize * .25,
                  right: defaultSize * .25,
                ),
                child: Slider(
                  value: settings.fontSize,
                  min: 14.0,
                  max: 28.0,
                  divisions: 7,
                  label: settings.fontSize.toInt().toString(),
                  onChanged: (double value) {
                    settings.setFontSize(value);
                  },
                ),
              ),
              contentPadding: EdgeInsets.zero,
            ),
            Divider(height: defaultSize),
            SwitchListTile(
              value: settings.repeatRefrain,
              onChanged: (value) {
                settings.setRepeatRefrain(value);
              },
              contentPadding: EdgeInsets.zero,
              title: Text(
                l10n.repeatRefrain,
                style: textTheme.titleMedium!.copyWith(
                  fontSize: defaultSize * .9,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
              subtitle: Text(
                l10n.repeatRefrainDescription,
                style: textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
