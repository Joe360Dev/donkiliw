import 'package:flutter/material.dart';
import 'package:hymns/pages/collections_page.dart';
import 'package:hymns/pages/themes_page.dart';
import 'package:hymns/pages/home_page.dart';
import 'package:hymns/pages/settings_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final PageController _pageController = PageController(
    initialPage: 0,
  );
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    ThemesPage(),
    CollectionsPage(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentIndex = _pageController.page?.round() ?? 0;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          _pageController.jumpToPage(index);
        },
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: l10n.home,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: l10n.themes,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.playlist_play),
            label: l10n.collections,
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
