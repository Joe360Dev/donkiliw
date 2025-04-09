import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/models/hymn_theme.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:hymns/widgets/hymn_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ThemesPage extends StatefulWidget {
  const ThemesPage({super.key});
  static const routeName = '/themes';

  @override
  State<ThemesPage> createState() => _ThemesPageState();
}

class _ThemesPageState extends State<ThemesPage>
    with AutomaticKeepAliveClientMixin {
  int _selectedHymnTheme = 1;
  late Future<List<HymnTheme>> _hymnThemeFuture;
  late Future<List<Hymn>> _hymnsFuture;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadHymnThemes();
    _loadThemeHymns();
  }

  void _loadHymnThemes() {
    final dbHelper = DatabaseHelper();
    _hymnThemeFuture = dbHelper.getHymnThemes();
  }

  void _loadThemeHymns() {
    final dbHelper = DatabaseHelper();
    _hymnsFuture = dbHelper.getHymnsByTheme(
      _selectedHymnTheme,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    super.build(context);

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          l10n.exploreByTheme,
          style: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(defaultSize * 2.7),
          child: Container(
            height: defaultSize * 2.7,
            color: colorScheme.surface,
            child: FutureBuilderWrapper(
              dense: true,
              future: _hymnThemeFuture,
              builder: (hymnThemes) {
                return ListView.separated(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: hymnThemes.length,
                  padding: EdgeInsets.symmetric(
                    horizontal: defaultSize * .5,
                  ),
                  separatorBuilder: (context, index) {
                    return const SizedBox(width: 10);
                  },
                  itemBuilder: (context, index) {
                    final hymnTheme = hymnThemes[index];
                    final isSelected = _selectedHymnTheme == hymnTheme.id;
                    return FilterChip(
                      showCheckmark: false,
                      padding: EdgeInsets.all(
                        defaultSize * .5,
                      ),
                      selected: isSelected,
                      selectedColor: colorScheme.primary,
                      backgroundColor: colorScheme.surfaceContainerLow,
                      avatar: SvgPicture.asset(
                        'assets/svg_icons/${hymnTheme.iconName}',
                        colorFilter: ColorFilter.mode(
                          isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.primary,
                          BlendMode.srcIn,
                        ),
                      ),
                      label: Text(
                        hymnTheme.name,
                        style: GoogleFonts.notoSans().copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? colorScheme.onPrimary : null,
                        ),
                      ),
                      onSelected: (bool value) {
                        setState(() {
                          _selectedHymnTheme = hymnTheme.id!;
                          _loadThemeHymns();
                        });
                      },
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
      body: FutureBuilderWrapper(
        future: _hymnsFuture,
        builder: (hymns) {
          return ListView.separated(
            itemCount: hymns.length,
            padding: EdgeInsets.symmetric(
              horizontal: defaultSize * .5,
              vertical: defaultSize * .3,
            ),
            separatorBuilder: (_, index) => SizedBox(
              height: defaultSize * .25,
            ),
            itemBuilder: (context, index) {
              final hymn = hymns[index];
              return HymnListTile(
                hymn: hymn,
                contextHymns: hymns,
              );
            },
          );
        },
      ),
    );
  }
}
