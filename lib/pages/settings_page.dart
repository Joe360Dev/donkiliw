import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/pages/about_page.dart';
import 'package:hymns/pages/appearence_setting_page.dart';
import 'package:hymns/pages/language_setting_page.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        centerTitle: false,
        title: Text(
          l10n.settings,
          style: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          vertical: defaultSize * .5,
        ),
        children: [
          SwitchListTile(
            value: false,
            onChanged: null,
            title: Builder(builder: (ctx) {
              var defaultTextStyle = DefaultTextStyle.of(ctx);
              return Text(
                l10n.connectedMode,
                style: defaultTextStyle.style.copyWith(
                  fontSize: textTheme.titleMedium!.fontSize,
                  color: colorScheme.brightness == Brightness.dark
                      ? Colors.grey.shade600
                      : null,
                ),
              );
            }),
            subtitle: Builder(builder: (ctx) {
              return Padding(
                padding: const EdgeInsets.only(top: 5.0),
                child: Text(
                  l10n.connectedModeDescription,
                  style: DefaultTextStyle.of(ctx).style.copyWith(
                        fontSize: defaultSize * .6,
                        color: colorScheme.brightness == Brightness.dark
                            ? Colors.grey.shade600
                            : null,
                      ),
                ),
              );
            }),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                LanguageSettingsPage.routeName,
              );
            },
            title: Text(l10n.languageLabel),
            trailing: IntrinsicWidth(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.language,
                    style: textTheme.bodyMedium!.copyWith(
                      fontSize: defaultSize * .75,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 5.0),
                  Icon(
                    CupertinoIcons.chevron_right,
                  ),
                ],
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                AppearenceSettingPage.routeName,
              );
            },
            title: Text(l10n.appearance),
            trailing: Padding(
              padding: const EdgeInsets.only(
                right: 5.0,
              ),
              child: Icon(
                CupertinoIcons.chevron_right,
              ),
            ),
          ),
          ListTile(
            onTap: () {
              Navigator.of(context).pushNamed(
                AboutPage.routeName,
              );
            },
            title: Text(l10n.about),
            trailing: Padding(
              padding: const EdgeInsets.only(
                right: 5.0,
              ),
              child: Icon(
                CupertinoIcons.chevron_right,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
