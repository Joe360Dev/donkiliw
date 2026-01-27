import 'package:flutter/material.dart';
import 'package:donkiliw/pages/main_page.dart';
import 'package:donkiliw/providers/settings_provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:donkiliw/utils/app_theme.dart';
import 'package:donkiliw/utils/page_router.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';
import 'package:upgrader/upgrader.dart';
import 'package:flutter/services.dart';
import 'package:donkiliw/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const MyApp());
}

// Global key for accessing the navigator from anywhere
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

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
              debugShowCheckedModeBanner: false,
              navigatorKey: navigatorKey,
              title: 'Donkiliw',
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
                GlobalCupertinoLocalizations.delegate,
              ],
              routes: PageRouter.routes,
              onGenerateRoute: PageRouter.onGenerateRoute,
              home: UpgradeAlert(
                upgrader: Upgrader(
                  countryCode: locale.countryCode,
                  languageCode: locale.languageCode,
                  debugLogging: true,
                  debugDisplayAlways: true, // Forces dialog
                ),
                child: const MainPage(),
              ),
            ),
          );
        },
      ),
    );
  }
}
