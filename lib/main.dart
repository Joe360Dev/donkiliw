import 'package:flutter/material.dart';
import 'package:hymns/pages/main_page.dart';
import 'package:hymns/providers/settings_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hymns/utils/app_theme.dart';
import 'package:hymns/utils/page_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SettingsProvider(),
      child: Consumer<SettingsProvider>(
        builder: (_, settings, child) {
          final appTheme = AppTheme(
            context: context,
            seedColor: settings.themeColor,
          );
          final locale = Locale(
            settings.languageCode,
            settings.languageCountryCode,
          );

          return ToastificationWrapper(
            child: MaterialApp(
              title: 'Hymns App',
              theme: appTheme.buildLightTheme(),
              darkTheme: appTheme.buildDarkTheme(),
              themeMode: settings.themeMode,
              locale: locale,
              supportedLocales: const [
                Locale('fr', 'FR'),
                Locale('bm', 'ML'),
                Locale('en', 'US'),
              ],
              localizationsDelegates: [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              routes: PageRouter.routes,
              onGenerateRoute: PageRouter.onGenerateRoute,
              home: const MainPage(),
            ),
          );
        },
      ),
    );
  }
}
