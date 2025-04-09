import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:hymns/widgets/hymn_list_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({
    super.key,
    this.query,
  });

  final String? query;
  static const routeName = '/search';

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late Future<Map<String, List<Hymn>>> _searchResultsFuture;
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<int?> _resultCount = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.query ?? '';
    _searchResultsFuture = _searchHymns(widget.query ?? '');
  }

  Future<Map<String, List<Hymn>>> _searchHymns(String query) async {
    final dbHelper = DatabaseHelper();
    final searchResults = await dbHelper.searchHymns(query);
    int count = 0;
    searchResults.forEach((key, hl) => count += hl.length);
    _resultCount.value = count;
    return searchResults;
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchResultsFuture = _searchHymns(value);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _resultCount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final specialChars = ['ɛ', 'ɔ', 'ŋ', 'ɲ'];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        automaticallyImplyLeading: false,
        title: SearchBar(
          autoFocus: true,
          hintText: l10n.searchAnHymn,
          elevation: WidgetStatePropertyAll(0),
          controller: _searchController,
          textInputAction: TextInputAction.search,
          keyboardType: TextInputType.text,
          textCapitalization: TextCapitalization.none,
          padding: WidgetStatePropertyAll(
            EdgeInsets.only(
              left: defaultSize * .25,
            ),
          ),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHighest.withAlpha(50),
          ),
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.notoSans().copyWith(
              fontSize: defaultSize * 0.8,
              fontWeight: FontWeight.w500,
              color: colorScheme.onPrimary,
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: defaultSize * 2,
          ),
          trailing: [
            IconButton(
              onPressed: () {
                _searchController.clear();
                _onSearchChanged(
                  _searchController.text,
                );
              },
              icon: Icon(
                Icons.clear,
                color: colorScheme.onPrimary,
                size: defaultSize * 0.9,
              ),
            ),
          ],
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                defaultSize * 0.25,
              ),
            ),
          ),
          onChanged: _onSearchChanged,
          onSubmitted: _onSearchChanged,
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            defaultSize * 3,
          ),
          child: Container(
            width: double.infinity,
            color: colorScheme.surface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: defaultSize * 2,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: specialChars.length,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(
                      vertical: defaultSize * .25,
                    ),
                    itemBuilder: (_, index) {
                      final char = specialChars[index];
                      return TextButton(
                        onPressed: () {
                          _searchController.text += char;
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              defaultSize * .25,
                            ),
                          ),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: defaultSize,
                          ),
                          child: Text(
                            char,
                            style: GoogleFonts.notoSans().copyWith(
                              fontSize: defaultSize,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                ValueListenableBuilder<int?>(
                  valueListenable: _resultCount,
                  builder: (_, value, __) {
                    return Text(
                      l10n.countResult(value ?? 0),
                      style: GoogleFonts.notoSans().copyWith(
                        fontSize: defaultSize * 0.8,
                        fontWeight: FontWeight.w500,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
                horizontal: defaultSize * .15,
              )),
            ),
            child: Text(
              l10n.cancel,
              style: GoogleFonts.notoSans().copyWith(
                fontSize: defaultSize * 0.75,
                fontWeight: FontWeight.w500,
                color: colorScheme.onPrimary,
              ),
            ),
          ),
          SizedBox(width: defaultSize * .5),
        ],
      ),
      body: FutureBuilderWrapper<Map<String, List<Hymn>>>(
        future: _searchResultsFuture,
        builder: (searchResults) {
          return ListView.builder(
            padding: EdgeInsets.all(defaultSize * 0.5),
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final bookName = searchResults.keys.toList()[index];
              final hymns = searchResults[bookName];
              return Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: defaultSize * .25,
                    ),
                    child: Text(
                      bookName,
                      style: textTheme.titleMedium!.copyWith(
                        fontSize: defaultSize,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                  ...hymns!.map(
                    (hymn) {
                      return HymnListTile(
                        hymn: hymn,
                        contextHymns: hymns,
                      );
                    },
                  )
                ],
              );
            },
          );
        },
      ),
    );
  }
}
