import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/circular_icon_text_button.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:hymns/widgets/hymn_list_tile.dart';
import 'package:toastification/toastification.dart';

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
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(ctx);
    final defaultSize = SizeConfig.defaultSize;
    final vh = SizeConfig.vh;

    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(defaultSize),
        ),
      ),
      constraints: BoxConstraints(
        minWidth: double.infinity,
        minHeight: vh * .3,
      ),
      builder: (BuildContext context) {
        return ListView(
          shrinkWrap: true,
          children: [
            Container(
              margin: EdgeInsets.only(
                bottom: defaultSize * .5,
              ),
              alignment: Alignment.center,
              child: Text(
                hymn.title,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.notoSans(
                  fontSize: defaultSize * .9,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularIconTextButton(
                  icon: hymn.isLiked ? Icons.favorite : Icons.favorite_border,
                  title: l10n.favorites,
                  onPressed: () {
                    _toggleLike(hymn);
                    Navigator.of(ctx).pop();
                  },
                ),
                CircularIconTextButton(
                  icon: Icons.bookmark_add_outlined,
                  title: l10n.collection,
                  onPressed: () {},
                ),
                CircularIconTextButton(
                  icon: Icons.share,
                  title: l10n.share,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _toggleLike(Hymn hymn) async {
    final l10n = AppLocalizations.of(context)!;

    final dbHelper = DatabaseHelper();
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    try {
      dbHelper.toggleHymnLike(hymn);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.toggleLikeResponseMessage(
            l10n.toggleLikeResponseMessage(
              hymn.isLiked ? 'liked' : 'unliked',
            ),
          ),
          style: textTheme.titleMedium!.copyWith(
            color: colorScheme.surface,
            fontSize: defaultSize * .85,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        alignment: Alignment.bottomCenter,
        icon: const Icon(Icons.check),
        showIcon: true,
        primaryColor: colorScheme.inversePrimary,
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.inversePrimary,
        closeOnClick: true,
        pauseOnHover: true,
        dragToClose: true,
        closeButton: ToastCloseButton(
          showType: CloseButtonShowType.none,
        ),
        autoCloseDuration: Duration(seconds: 2),
      );

      setState(() {
        _loadData();
      });
    } catch (e) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.errorTryAgain,
          style: textTheme.titleMedium!.copyWith(
            color: colorScheme.surface,
            fontSize: defaultSize * .85,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        alignment: Alignment.bottomCenter,
        icon: const Icon(Icons.check),
        showIcon: true,
        primaryColor: colorScheme.inversePrimary,
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.inversePrimary,
        closeOnClick: true,
        pauseOnHover: true,
        dragToClose: true,
        closeButton: ToastCloseButton(
          showType: CloseButtonShowType.none,
        ),
        autoCloseDuration: Duration(seconds: 2),
      );
    }
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
