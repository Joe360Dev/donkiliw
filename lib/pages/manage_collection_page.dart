import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/models/hymn_collection.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/collection_hymn_addition_bottom_sheet.dart';
import 'package:hymns/widgets/collection_hymn_list_tile.dart';
import 'package:hymns/widgets/dismissible_keyboard.dart';
import 'package:hymns/widgets/expandable_text.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:intl/intl.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ManageCollectionPage extends StatefulWidget {
  const ManageCollectionPage({
    super.key,
    required this.collection,
  });

  final HymnCollection collection;

  static const routeName = '/manage-collection';

  @override
  State<ManageCollectionPage> createState() => _ManageCollectionPageState();
}

class _ManageCollectionPageState extends State<ManageCollectionPage> {
  bool _isEditing = false;

  late Future<HymnCollection>? _futureCollection;
  late HymnCollection _collection;
  bool _hasChanges = false;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _collection = widget.collection;
    _titleController = TextEditingController(
      text: _collection.title,
    );
    _descriptionController = TextEditingController(
      text: _collection.description,
    );

    final dbHelper = DatabaseHelper();

    if (widget.collection.id != null) {
      _futureCollection = dbHelper
          .getHymnByCollection(widget.collection.id!)
          .then((collection) {
        setState(() {
          _collection = collection;
          _titleController.text = _collection.title ?? '';
          _descriptionController.text = _collection.description ?? '';
        });
        return collection;
      });
    } else {
      _futureCollection = Future.value(_collection);
    }
  }

  String _formatDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    final pattern = locale == 'en_US' ? 'MMMM d, yyyy' : 'd MMMM yyyy';
    final formatter = DateFormat(pattern, locale);
    return formatter.format(date);
  }

  void _showAddHymnBottomSheet(BuildContext ctx) async {
    if (_collection.id == null) await _saveChanges();
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CollectionHymnAdditionBottomSheet(
          collection: _collection,
        );
      },
    ).then((result) {
      if (result != null && result > 0) {
        setState(() {
          _hasChanges = true;
          _futureCollection = DatabaseHelper()
              .getHymnByCollection(
            _collection.id!,
          )
              .then((collection) {
            _collection = collection;
            return collection;
          });
        });
      }
    });
  }

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final Hymn item = _collection.hymns.removeAt(oldIndex);
      _collection.hymns.insert(newIndex, item);
      _hasChanges = true;
    });
    final dbHelper = DatabaseHelper();
    dbHelper.reorderHymnsInCollection(
      _collection.id!,
      _collection.hymns,
    );
  }

  Future<void> _removeHymn(Hymn hymn) async {
    final l10n = AppLocalizations.of(context)!;
    final dbHelper = DatabaseHelper();
    await dbHelper.removeHymnFromCollection(
      hymn.id!,
      _collection.id!,
    );
    setState(() {
      _collection.hymns.remove(hymn);
      _hasChanges = true;
    });

    if (mounted) {
      final defaultSize = SizeConfig.defaultSize;
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.hymnRemovedFromCollection,
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

  Future<void> _saveChanges() async {
    final dbHelper = DatabaseHelper();
    HymnCollection collection = HymnCollection(
      id: _collection.id,
      title: _titleController.text,
      description: _descriptionController.text,
    );
    collection.creationDate = _collection.creationDate;

    collection = await dbHelper.saveCollectionChanges(
      collection,
    );
    setState(() {
      _collection = collection.copyWith(
        hymns: _collection.hymns,
      );
      _isEditing = false;
      _hasChanges = true;
    });
    _titleController.text = _collection.title ?? '';
    _descriptionController.text = _collection.description ?? '';

    if (mounted) {
      final defaultSize = SizeConfig.defaultSize;
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(
          'Collection mise à avec succès !',
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
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilderWrapper<HymnCollection>(
      future: _futureCollection ?? Future.value(_collection),
      builder: (collection) {
        return DismissibleKeyboard(
          child: WillPopScope(
            onWillPop: () async {
              Navigator.pop(context, _hasChanges);
              return true;
            },
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                centerTitle: false,
                titleSpacing: 0,
                automaticallyImplyLeading: true,
                title: Text(
                  (_isEditing)
                      ? l10n.editCollection
                      : _collection.title ?? l10n.noTitleCollection,
                  style: GoogleFonts.notoSans().copyWith(
                    fontSize: defaultSize * .9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: _isEditing
                        ? _saveChanges
                        : () {
                            setState(() {
                              _isEditing = !_isEditing;
                            });
                          },
                    style: TextButton.styleFrom(
                      overlayColor: colorScheme.onPrimary.withAlpha(50),
                    ),
                    child: Text(
                      _isEditing ? l10n.save : l10n.edit,
                      style: GoogleFonts.notoSans().copyWith(
                        color: colorScheme.onPrimary,
                        fontSize: defaultSize * .75,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              body: Container(
                padding: EdgeInsets.all(defaultSize * .25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.all(defaultSize * .5),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerLow.withAlpha(100),
                        borderRadius: BorderRadius.circular(defaultSize * .5),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_isEditing) ...[
                            Text(
                              l10n.collectionName,
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize * .9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: defaultSize * .5),
                            TextField(
                              controller: _titleController,
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize * .75,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: '...',
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: defaultSize * .5,
                                  horizontal: defaultSize * .5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    defaultSize * .5,
                                  ),
                                  borderSide: BorderSide(
                                    width: .5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    defaultSize * .5,
                                  ),
                                  borderSide: BorderSide(
                                    width: .5,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: defaultSize * .5),
                            Text(
                              l10n.description,
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize * .9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: defaultSize * .5),
                            TextField(
                              controller: _descriptionController,
                              maxLines: 3,
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize * .75,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: l10n.collectionDescription,
                                hintStyle: GoogleFonts.notoSans().copyWith(
                                  fontSize: defaultSize * .75,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.secondary.withAlpha(200),
                                ),
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: defaultSize * .5,
                                  horizontal: defaultSize * .5,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    defaultSize * .5,
                                  ),
                                  borderSide: BorderSide(
                                    width: .5,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                    defaultSize * .5,
                                  ),
                                  borderSide: BorderSide(
                                    width: .5,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                            )
                          ] else ...[
                            Text(
                              _collection.title ?? l10n.noTitle,
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(
                              height: defaultSize * .25,
                              width: double.infinity,
                            ),
                            ExpandableText(
                              text: _collection.description,
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize * 0.75,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(height: defaultSize * .25),
                            Text(
                              l10n.createdAt(
                                  _formatDate(collection.creationDate)),
                              style: GoogleFonts.notoSans().copyWith(
                                fontSize: defaultSize * 0.7,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ]
                        ],
                      ),
                    ),
                    SizedBox(height: defaultSize * .5),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(defaultSize * .5),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow.withAlpha(100),
                          borderRadius: BorderRadius.circular(defaultSize * .5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                              contentPadding: EdgeInsetsDirectional.zero,
                              title: Text(
                                l10n.hymns,
                                style: GoogleFonts.notoSans().copyWith(
                                  fontSize: defaultSize * .9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              trailing: TextButton.icon(
                                onPressed: () {
                                  _showAddHymnBottomSheet(context);
                                },
                                label: Text(
                                  l10n.hymns,
                                  style: GoogleFonts.notoSans().copyWith(
                                    fontSize: defaultSize * .8,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                icon: Icon(
                                  Icons.add_box_outlined,
                                  size: defaultSize,
                                  color: colorScheme.primary,
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor: colorScheme.primary,
                                  backgroundColor:
                                      colorScheme.surfaceContainerHigh,
                                ),
                              ),
                            ),
                            SizedBox(height: defaultSize * .5),
                            Expanded(
                              child: ReorderableListView(
                                shrinkWrap: true,
                                onReorder: _onReorder,
                                children: _collection.hymns.map(
                                  (hymn) {
                                    return CollectionHymnListTile(
                                      key: Key(hymn.id.toString()),
                                      contextHymns: _collection.hymns,
                                      hymn: hymn,
                                      onDelete: () => _removeHymn(hymn),
                                    );
                                  },
                                ).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
