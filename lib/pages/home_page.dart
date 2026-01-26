import 'package:donkiliw/pages/favorites_page.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/models/hymn_book.dart';
import 'package:donkiliw/models/hymn_theme.dart';
import 'package:donkiliw/pages/search_page.dart';
import 'package:donkiliw/pages/theme_details_page.dart';
import 'package:donkiliw/utils/database_helper.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/dismissible_keyboard.dart';
import 'package:donkiliw/widgets/future_builder_wrapper.dart';
import 'package:donkiliw/widgets/hymn_book_tile.dart';
import 'package:donkiliw/widgets/hymn_theme_card.dart';
import 'package:donkiliw/l10n/app_localizations.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  late Future<Map<String, dynamic>> _dataLoadFuture;

  @override
  void initState() {
    super.initState();
    _dataLoadFuture = _loadData();
  }

  Future<Map<String, dynamic>> _loadData() async {
    final Map<String, dynamic> data = {};
    final dbHelper = DatabaseHelper();
    final books = await dbHelper.getHymnBooks();
    final hymnThemes = await dbHelper.getHymnThemes();

    data['hymn_books'] = books;
    data['hymn_themes'] = hymnThemes;

    return data;
  }

  Widget _buildThematics(List<HymnTheme> hymnThemes) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: defaultSize * .55,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.exploreByTheme,
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: defaultSize,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ThemeDetailsPage.routeName,
                  );
                },
                child: Row(
                  children: [
                    Text(
                      l10n.seeMore,
                      style: textTheme.labelLarge!.copyWith(
                        fontSize: textTheme.titleSmall!.fontSize,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: textTheme.titleMedium!.fontSize,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: defaultSize * .1,
        ),
        // Thematics Cards
        SizedBox(
          height: defaultSize * 3.5,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: hymnThemes.length,
            padding: EdgeInsets.symmetric(
              horizontal: defaultSize * .55,
            ),
            separatorBuilder: (context, index) {
              return const SizedBox(width: 10);
            },
            itemBuilder: (context, index) {
              final hymnTheme = hymnThemes[index];
              return HymnThemeCard(
                title: hymnTheme.name,
                themeId: hymnTheme.id!,
                iconPath: hymnTheme.iconName,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHymnBooks(List<HymnBook> hymnBooks) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: defaultSize * .55,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.exploreBooks,
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  fontSize: defaultSize,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: defaultSize * .1),
        SizedBox(
          height: defaultSize * 19.5,
          child: GridView.count(
            crossAxisCount: 2,
            physics: NeverScrollableScrollPhysics(),
            mainAxisSpacing: defaultSize * .8,
            crossAxisSpacing: defaultSize * .8,
            padding: EdgeInsets.symmetric(
              horizontal: defaultSize * .75,
              vertical: defaultSize * .5,
            ),
            childAspectRatio: 2 / 1.95,
            children: List.generate(
              hymnBooks.length,
              (index) {
                final hymnBook = hymnBooks[index];
                return HymnBookTile(
                  hymnBookId: hymnBook.id!,
                  title: hymnBook.name,
                  coverImagePath: hymnBook.coverImagePath,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    super.build(context);

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return DismissibleKeyboard(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(
            kToolbarHeight * 2.5,
          ),
          child: AppBar(
            elevation: 4,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(
                  defaultSize * 1.75,
                ),
                bottomRight: Radius.circular(
                  defaultSize * 1.75,
                ),
              ),
            ),
            flexibleSpace: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultSize * 0.5,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      l10n.welcomeToDonkiliw,
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onPrimary,
                        fontSize: defaultSize,
                      ),
                    ),
                    SizedBox(height: defaultSize * 0.5),
                    SearchBar(
                      onSubmitted: (query) {
                        Navigator.of(context).pushNamed(
                          SearchPage.routeName,
                          arguments: {
                            'query': query,
                          },
                        );
                      },
                      hintText: l10n.searchAnHymn,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.search,
                      elevation: const WidgetStatePropertyAll(0),
                      textStyle: WidgetStatePropertyAll(
                        GoogleFonts.notoSans().copyWith(
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      leading: Icon(
                        Icons.search,
                        color: colorScheme.onSurface,
                      ),
                      backgroundColor: WidgetStatePropertyAll(
                        colorScheme.surface,
                      ),
                      constraints: BoxConstraints(
                        minHeight: kToolbarHeight * 0.85,
                        maxWidth: SizeConfig.vw * 0.85,
                      ),
                      shape: WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            defaultSize * 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.favorite_border,
                  size: defaultSize * 1.5,
                ),
                onPressed: () async {
                  // final dbHelper = DatabaseHelper();
                  // await dbHelper.resetDatabase();
                  // await dbHelper.importHymnsFromJson();
                  // await dbHelper.setHymnThemes();

                  Navigator.pushNamed(
                    context,
                    FavoritesPage.routeName,
                  );
                },
              ),
              SizedBox(width: defaultSize * 0.25),
            ],
          ),
        ),
        body: FutureBuilderWrapper(
            future: _dataLoadFuture,
            builder: (data) {
              final List<HymnBook> hymnBooks = data['hymn_books'] ?? [];
              final List<HymnTheme> hymnThemes = data['hymn_themes'] ?? [];

              return SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  vertical: defaultSize * .6,
                  // horizontal: defaultSize,
                ),
                child: Column(
                  children: [
                    // Thematics
                    _buildThematics(hymnThemes),

                    SizedBox(height: defaultSize * 1.1),
                    _buildHymnBooks(hymnBooks),
                    SizedBox(height: defaultSize * .25),
                    Divider(
                      color: colorScheme.onSurface.withAlpha(128),
                      thickness: .5,
                      indent: defaultSize * 5,
                      endIndent: defaultSize * 5,
                    ),
                    SizedBox(height: defaultSize * .1),

                    RichText(
                      text: TextSpan(
                        text: l10n.donkiliwQuote,
                        style: textTheme.bodyLarge!.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w500,
                        ),
                        children: [
                          TextSpan(
                            text: '\n${l10n.donkiliwQuoteReference}',
                            style: GoogleFonts.notoSans(
                              fontWeight: FontWeight.w600,
                              color: colorScheme.primary,
                              fontSize: defaultSize * .9,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: defaultSize * .3),
                  ],
                ),
              );
            }),
      ),
    );
  }
}
