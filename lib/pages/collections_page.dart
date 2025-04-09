import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn_collection.dart';
import 'package:hymns/pages/manage_collection_page.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:hymns/widgets/hymn_collection_card.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CollectionsPage extends StatefulWidget {
  const CollectionsPage({super.key});

  @override
  State<CollectionsPage> createState() => _CollectionsPageState();
}

class _CollectionsPageState extends State<CollectionsPage>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  late Future<List<HymnCollection>> _collectionsFuture;

  @override
  void initState() {
    super.initState();
    _refreshCollections();
  }

  void _refreshCollections() {
    setState(() {
      final dbHelper = DatabaseHelper();
      _collectionsFuture = dbHelper.getCollectionsData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    super.build(context);

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        title: Text(
          l10n.myCollections,
          style: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            defaultSize * 3,
          ),
          child: Flexible(
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: defaultSize * .5,
                vertical: defaultSize * .25,
              ),
              color: colorScheme.surface,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    ManageCollectionPage.routeName,
                    arguments: {
                      'collection': HymnCollection(),
                    },
                  ).then((result) {
                    if (result == true) _refreshCollections();
                  });
                },
                style: OutlinedButton.styleFrom(
                  elevation: 1,
                  shadowColor: theme.shadowColor.withAlpha(100),
                  overlayColor: colorScheme.surfaceContainerLowest,
                  backgroundColor: colorScheme.primary,
                  padding: EdgeInsets.symmetric(
                    vertical: defaultSize * .55,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      defaultSize * .35,
                    ),
                  ),
                ),
                icon: Icon(
                  Icons.add_box_outlined,
                  size: defaultSize * 1.2,
                  color: colorScheme.onPrimary,
                ),
                label: Text(
                  l10n.createNewCollection,
                  style: textTheme.titleMedium!.copyWith(
                    fontSize: defaultSize * .85,
                    height: 1,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          _refreshCollections();
        },
        child: FutureBuilderWrapper<List<HymnCollection>>(
          future: _collectionsFuture,
          errorText: l10n.errorWhenLoadingCollections,
          emptyText: l10n.createYourFirstCollection,
          loadingText: l10n.loadingCollections,
          builder: (collections) {
            return ListView.separated(
              itemCount: collections.length,
              padding: EdgeInsets.symmetric(
                horizontal: defaultSize * .25,
              ),
              separatorBuilder: (_, index) => Divider(
                endIndent: defaultSize * .5,
                indent: defaultSize * .5,
                thickness: 2,
                color: colorScheme.outlineVariant,
              ),
              itemBuilder: (_, index) {
                return HymnCollectionCard(
                  collection: collections[index],
                  onRefresh: () {
                    _refreshCollections();
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
