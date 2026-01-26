import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/models/hymn_collection.dart';
import 'package:donkiliw/pages/hymn_page.dart';
import 'package:donkiliw/pages/manage_collection_page.dart';
import 'package:donkiliw/utils/database_helper.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/empty_content_widget.dart';
import 'package:donkiliw/widgets/hymn_tile.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:donkiliw/l10n/app_localizations.dart';
import 'package:donkiliw/models/hymn.dart';

class HymnCollectionCard extends StatefulWidget {
  const HymnCollectionCard({
    super.key,
    required this.collection,
    this.onRefresh,
  });
  final HymnCollection collection;
  final VoidCallback? onRefresh;

  @override
  State<HymnCollectionCard> createState() => _HymnCollectionCardState();
}

class _HymnCollectionCardState extends State<HymnCollectionCard> {
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = locale == 'en_US' ? 'MMMM d, yyyy' : 'd MMMM yyyy';
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  Future<void> _deleteCollection() async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteCollection(
      widget.collection.id!,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final vh = SizeConfig.vh;
    final vw = SizeConfig.vw;
    final hymns = widget.collection.hymns;
    final List<Hymn> uniqueHymns = [];
    final Set<String> seenGroups = {};
    for (var h in hymns) {
      final key = '${h.hymnBookId}_${h.number}';
      if (!seenGroups.contains(key)) {
        uniqueHymns.add(h);
        seenGroups.add(key);
      }
    }

    return Card(
      elevation: 1,
      shadowColor: theme.shadowColor.withAlpha(100),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(
          defaultSize * .5,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ExpansionPanelList(
              expandedHeaderPadding: EdgeInsets.zero,
              expansionCallback: (int index, bool isExpanded) {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              children: [
                ExpansionPanel(
                  canTapOnHeader: true,
                  highlightColor: colorScheme.surfaceContainerLowest,
                  headerBuilder: (context, isExpanded) {
                    return ListTile(
                      contentPadding: EdgeInsetsDirectional.symmetric(
                        horizontal: defaultSize * .5,
                      ),
                      title: Text(
                        widget.collection.title!,
                        style: GoogleFonts.notoSans(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.primary,
                          fontSize: defaultSize * .9,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: defaultSize * .25,
                          ),
                          Text(_formatDate(widget.collection.creationDate)),
                          Divider(
                            endIndent: defaultSize * 7,
                            thickness: 3,
                            color: colorScheme.surfaceContainerHighest,
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        onPressed: hymns.isEmpty
                            ? null
                            : () {
                                Navigator.of(context).pushNamed(
                                  HymnPage.routeName,
                                  arguments: {
                                    'initial_index': hymns.indexOf(hymns.first),
                                    'context_hymns': hymns,
                                  },
                                );
                              },
                        style: IconButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              defaultSize * .35,
                            ),
                          ),
                        ),
                        icon: Icon(
                          Icons.play_circle_outline_rounded,
                          size: defaultSize * 1.3,
                          color: colorScheme.primary.withAlpha(150),
                        ),
                      ),
                    );
                  },
                  body: Container(
                    color: colorScheme.surface,
                    constraints: BoxConstraints(
                      maxHeight: vh * .35,
                    ),
                    child: widget.collection.hymns.isEmpty
                        ? SizedBox(
                            width: vw * .75,
                            child: EmptyContentWidget(
                              emptyText: l10n.addHymnsToYourCollection,
                            ),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: uniqueHymns.length,
                            itemBuilder: (context, index) {
                              final hymn = uniqueHymns[index];
                              return HymnTile(
                                hymn: hymn,
                                contextHymns: hymns,
                              );
                            },
                          ),
                  ),
                  isExpanded: _isExpanded,
                ),
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                horizontal: defaultSize * .55,
              ),
              decoration: BoxDecoration(
                color: colorScheme.surface,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.hymnsCount(uniqueHymns.length),
                    style: textTheme.bodySmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                            ManageCollectionPage.routeName,
                            arguments: {
                              'collection': widget.collection,
                            },
                          ).then((result) {
                            if (result == true) {
                              widget.onRefresh?.call();
                            }
                          });
                        },
                        style: TextButton.styleFrom(
                          overlayColor: colorScheme.onTertiaryContainer,
                        ),
                        child: Text(
                          l10n.editCollection,
                          style: TextStyle(
                            color: colorScheme.tertiary,
                          ),
                        ),
                      ),
                      IconButton(
                        style: IconButton.styleFrom(
                          elevation: 0,
                          backgroundColor: colorScheme.errorContainer,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              defaultSize * .35,
                            ),
                          ),
                        ),
                        onPressed: () {
                          _deleteCollection().then(
                            (_) {
                              widget.onRefresh?.call();
                              toastification.show(
                                type: ToastificationType.success,
                                style: ToastificationStyle.flat,
                                title: Text(
                                  l10n.collectionDeleted,
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
                            },
                          );
                        },
                        icon: Icon(
                          CupertinoIcons.delete_simple,
                          color: colorScheme.onErrorContainer,
                          size: defaultSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
