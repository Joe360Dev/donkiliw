import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/pages/search_page.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/hymn_list_view_mode_num.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:hymns/widgets/hymn_grid_tile.dart';
import 'package:hymns/widgets/hymn_list_tile.dart';

class HymnBookPage extends StatefulWidget {
  const HymnBookPage({
    super.key,
    required this.hymnBookId,
    required this.title,
  });

  final int hymnBookId;
  final String title;

  static const String routeName = '/hymn-book';

  @override
  State<HymnBookPage> createState() => _HymnBookPageState();
}

class _HymnBookPageState extends State<HymnBookPage> {
  HymnListViewModeNum _listViewMode = HymnListViewModeNum.gridView;
  late Future<List<Hymn>> _hymnsFuture;
  late List<Hymn> _hymnsData;
  final ValueNotifier<int> _bookSize = ValueNotifier(999);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final dbHelper = DatabaseHelper();
    _hymnsFuture = dbHelper.getHymnsByBook(widget.hymnBookId).then((hymns) {
      _hymnsData = hymns;
      _bookSize.value = hymns.length;
      return _sortHymns(hymns, _listViewMode);
    });
  }

  List<Hymn> _sortHymns(List<Hymn> hymns, HymnListViewModeNum mode) {
    final sortedHymns = List<Hymn>.from(hymns);
    switch (mode) {
      case HymnListViewModeNum.gridView:
      case HymnListViewModeNum.listViewNumericalOrder:
        sortedHymns.sort((a, b) => a.number.compareTo(b.number));
        break;
      case HymnListViewModeNum.listViewAlphabeticalOrder:
        sortedHymns.sort((a, b) => a.title.compareTo(b.title));
        break;
    }
    return sortedHymns;
  }

  Widget _buildHymnList(List<Hymn> hymns) {
    final defaultSize = SizeConfig.defaultSize;
    switch (_listViewMode) {
      case HymnListViewModeNum.gridView:
        return GridView.builder(
          shrinkWrap: true,
          itemCount: hymns.length,
          gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: defaultSize * 3.2,
            crossAxisSpacing: defaultSize * .55,
            mainAxisSpacing: defaultSize * .55,
            childAspectRatio: 1.1 / 1,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: defaultSize * .55,
            vertical: defaultSize * .55,
          ),
          itemBuilder: (_, index) {
            final hymn = hymns[index];
            return HymnGridTile(
              hymn: hymn,
              contextHymns: _hymnsData,
            );
          },
        );
      case HymnListViewModeNum.listViewNumericalOrder:
      case HymnListViewModeNum.listViewAlphabeticalOrder:
        return ListView.separated(
          shrinkWrap: true,
          itemCount: hymns.length,
          separatorBuilder: (context, index) => SizedBox(
            height: defaultSize * .5,
          ),
          padding: EdgeInsets.symmetric(
            vertical: defaultSize * .25,
            horizontal: defaultSize * .25,
          ),
          itemBuilder: (_, index) {
            final hymn = hymns[index];
            return HymnListTile(
              hymn: hymn,
              contextHymns: _hymnsData,
            );
          },
        );
    }
  }

  @override
  void dispose() {
    _bookSize.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 0,
        title: Text(
          widget.title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: defaultSize * .9,
            textStyle: textTheme.titleMedium,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).pushNamed(
                SearchPage.routeName,
              );
            },
            icon: Icon(
              Icons.search,
              size: defaultSize * 1.5,
            ),
            padding: EdgeInsets.symmetric(
              vertical: defaultSize * .25,
              horizontal: defaultSize * .25,
            ),
          ),
          SizedBox(width: defaultSize * .5),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(defaultSize * 2),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: defaultSize * .25,
            ),
            child: SegmentedButton<HymnListViewModeNum>(
              segments: <ButtonSegment<HymnListViewModeNum>>[
                ButtonSegment<HymnListViewModeNum>(
                  value: HymnListViewModeNum.gridView,
                  label: Text(
                    'Numéro',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w500,
                      fontSize: defaultSize * .7,
                      textStyle: textTheme.titleMedium,
                    ),
                  ),
                  icon: Icon(Icons.numbers),
                ),
                ButtonSegment<HymnListViewModeNum>(
                  value: HymnListViewModeNum.listViewNumericalOrder,
                  label: ValueListenableBuilder<int>(
                    valueListenable: _bookSize,
                    builder: (_, value, __) => Text(
                      'Titre 1-$value',
                      style: GoogleFonts.notoSans(
                        fontWeight: FontWeight.w500,
                        fontSize: defaultSize * .7,
                        textStyle: textTheme.titleMedium,
                      ),
                    ),
                  ),
                  icon: Icon(Icons.format_list_numbered_rounded),
                ),
                ButtonSegment<HymnListViewModeNum>(
                  value: HymnListViewModeNum.listViewAlphabeticalOrder,
                  label: Text(
                    'Titre A-Z',
                    style: GoogleFonts.notoSans(
                      fontWeight: FontWeight.w500,
                      fontSize: defaultSize * .7,
                      textStyle: textTheme.titleMedium,
                    ),
                  ),
                  icon: Icon(Icons.sort_by_alpha),
                ),
              ],
              selected: <HymnListViewModeNum>{_listViewMode},
              onSelectionChanged: (Set<HymnListViewModeNum> newSelection) {
                setState(() {
                  _listViewMode = newSelection.first;
                  _hymnsFuture = Future.value(
                    _sortHymns(_hymnsData, _listViewMode),
                  );
                });
              },
            ),
          ),
        ),
      ),
      body: FutureBuilderWrapper(
        future: _hymnsFuture,
        builder: (hymns) {
          return _buildHymnList(hymns);
        },
      ),
    );
  }
}
