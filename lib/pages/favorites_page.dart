import 'package:donkiliw/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/models/hymn.dart';
import 'package:donkiliw/utils/database_helper.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/future_builder_wrapper.dart';
import 'package:donkiliw/widgets/hymn_list_tile.dart';
import 'package:donkiliw/widgets/hymn_actions_bottom_sheet.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});
  static const routeName = '/favorites';

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<Hymn>> _futureFavorites;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final dbHelper = DatabaseHelper();
    _futureFavorites = dbHelper.getFavoriteHymns();
  }

  void _showBottomSheetWith(BuildContext ctx, Hymn hymn) {
    HymnActionsBottomSheet.show(ctx, hymn, onUpdate: () {
      setState(() {
        _loadData();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.myFavorites,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.notoSans(
            fontWeight: FontWeight.bold,
            fontSize: defaultSize,
            textStyle: textTheme.titleMedium,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [],
      ),
      body: FutureBuilderWrapper(
        future: _futureFavorites,
        builder: (hymns) {
          return ListView.builder(
            itemCount: hymns.length,
            padding: EdgeInsets.symmetric(
              horizontal: defaultSize * .25,
            ),
            itemBuilder: (_, index) {
              final hymn = hymns[index];
              return HymnListTile(
                contextHymns: hymns,
                hymn: hymn,
                onActionTap: () {
                  _showBottomSheetWith(context, hymn);
                },
              );
            },
          );
        },
      ),
    );
  }
}
