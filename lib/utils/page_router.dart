import 'package:flutter/material.dart';
import 'package:hymns/pages/about_page.dart';
import 'package:hymns/pages/appearence_setting_page.dart';
import 'package:hymns/pages/favorites_page.dart';
import 'package:hymns/pages/hymn_book_page.dart';
import 'package:hymns/pages/hymn_page.dart';
import 'package:hymns/pages/language_setting_page.dart';
import 'package:hymns/pages/manage_collection_page.dart';
import 'package:hymns/pages/search_page.dart';
import 'package:hymns/pages/theme_details_page.dart';

class PageRouter {
  static final routes = {
    FavoritesPage.routeName: (ctx) => const FavoritesPage(),
    LanguageSettingsPage.routeName: (ctx) => const LanguageSettingsPage(),
    AppearenceSettingPage.routeName: (ctx) => const AppearenceSettingPage(),
    AboutPage.routeName: (ctx) => const AboutPage(),
  };

  static Route? onGenerateRoute(settings) {
    if (settings.name == HymnPage.routeName) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) {
          return HymnPage(
            initialIndex: args['initial_index'],
            contextHymns: args['context_hymns'],
          );
        },
      );
    } else if (settings.name == ThemeDetailsPage.routeName) {
      final args = settings.arguments as Map<String, dynamic>?;
      return MaterialPageRoute(
        builder: (_) {
          return ThemeDetailsPage(
            hymnThemeId: args?['hymn_theme_id'],
          );
        },
      );
    } else if (settings.name == HymnBookPage.routeName) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) {
          return HymnBookPage(
            hymnBookId: args['hymnBookId'],
            title: args['title'],
          );
        },
      );
    } else if (settings.name == ManageCollectionPage.routeName) {
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) {
          return ManageCollectionPage(
            collection: args['collection'],
          );
        },
      );
    } else if (settings.name == SearchPage.routeName) {
      final args =
          (settings.arguments ?? <String, dynamic>{}) as Map<String, dynamic>;
      return MaterialPageRoute(
        builder: (_) {
          return SearchPage(
            query: args['query'],
          );
        },
      );
    }
    assert(false, 'Need to implement ${settings.name}');
    return null;
  }
}
