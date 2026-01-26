import 'package:donkiliw/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/models/hymn.dart';
import 'package:donkiliw/models/hymn_collection.dart';
import 'package:donkiliw/utils/database_helper.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/dismissible_keyboard.dart';
import 'package:donkiliw/widgets/future_builder_wrapper.dart';
import 'package:toastification/toastification.dart';

class CollectionHymnAdditionBottomSheet extends StatefulWidget {
  final HymnCollection collection;

  const CollectionHymnAdditionBottomSheet({
    super.key,
    required this.collection,
  });

  @override
  State<CollectionHymnAdditionBottomSheet> createState() =>
      _CollectionHymnAdditionBottomSheetState();
}

class _CollectionHymnAdditionBottomSheetState
    extends State<CollectionHymnAdditionBottomSheet> {
  late Future<Map<String, List<Hymn>>> _hymnsDataFuture;
  final TextEditingController _searchController = TextEditingController();
  Map<String, List<Hymn>> _filteredHymnsData = {};
  final Set<int> _selectedHymnIds = {};

  @override
  void initState() {
    super.initState();
    final dbHelper = DatabaseHelper();
    _hymnsDataFuture = dbHelper.getHymns().then((hymnsData) {
      _filteredHymnsData = hymnsData;
      return hymnsData;
    });
    _selectedHymnIds.addAll(widget.collection.hymns.map(
      (h) => h.id!,
    ));
    _searchController.addListener(_filterHymns);
  }

  void _filterHymns() async {
    final query = _searchController.text.trim().toLowerCase();

    try {
      final hymnsData = await _hymnsDataFuture;

      setState(() {
        if (query.isEmpty) {
          _filteredHymnsData = Map.from(hymnsData);
        } else {
          _filteredHymnsData = hymnsData.map((key, bookHymns) {
            final filteredHymns = bookHymns.where((hymn) {
              final numberStr = hymn.number.toString();
              final titleStr = hymn.title.toLowerCase();
              return numberStr.contains(query) || titleStr.contains(query);
            }).toList();
            return MapEntry(key, filteredHymns);
          });
        }
      });
    } catch (e) {
      setState(() {
        _filteredHymnsData = {};
      });
    }
  }

  void _toggleHymnSelection(int hymnId) {
    setState(() {
      if (_selectedHymnIds.contains(hymnId)) {
        _selectedHymnIds.remove(hymnId);
      } else {
        _selectedHymnIds.add(hymnId);
      }
    });
  }

  Future<void> _addSelectedHymns() async {
    final l10n = AppLocalizations.of(context)!;

    final dbHelper = DatabaseHelper();
    for (final hymnId in _selectedHymnIds) {
      await dbHelper.addHymnToCollection(
        hymnId,
        widget.collection.id!,
      );
    }
    if (mounted) {
      final defaultSize = SizeConfig.defaultSize;
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      Navigator.pop(
        context,
        _selectedHymnIds.length,
      );

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.hymnsAddedToCollection(
            _selectedHymnIds.length,
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
    }
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: defaultSize * .5,
        horizontal: defaultSize * .75,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.addHymns,
            style: GoogleFonts.notoSans(
              fontSize: defaultSize * 0.9,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          IconButton.filled(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close),
            color: colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(defaultSize * 0.5),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.notoSans(
          fontSize: defaultSize * 0.75,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerHigh,
          contentPadding: EdgeInsets.symmetric(
            horizontal: defaultSize,
            vertical: defaultSize * 0.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              defaultSize * 0.5,
            ),
            borderSide: BorderSide.none,
          ),
          hintText: l10n.searchAnHymn,
          hintStyle: GoogleFonts.notoSans(
            fontSize: defaultSize * 0.75,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          ),
          suffixIcon: Icon(
            Icons.search,
            color: colorScheme.onSurface.withAlpha(200),
            size: defaultSize,
          ),
        ),
      ),
    );
  }

  Widget _buildHymnList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilderWrapper<Map<String, List<Hymn>>>(
      future: _hymnsDataFuture,
      errorText: l10n.errorWhenLoadingHymns,
      builder: (hymnData) {
        bool noResult = true;
        for (var key in _filteredHymnsData.keys) {
          noResult &= _filteredHymnsData[key]!.isEmpty;
        }
        if (noResult) {
          return Padding(
            padding: EdgeInsets.only(
              top: defaultSize,
            ),
            child: Text(
              l10n.noHymnFound,
              style: textTheme.titleMedium!.copyWith(
                fontSize: defaultSize * .75,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          );
        }
        return ListView.builder(
          itemCount: _filteredHymnsData.length,
          itemBuilder: (context, index) {
            final bookName = _filteredHymnsData.keys.toList()[index];
            final hymns = _filteredHymnsData[bookName];

            return Column(
              children: [
                if (hymns != null && hymns.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: defaultSize * .25,
                    ),
                    child: Text(
                      bookName,
                      style: textTheme.titleMedium!.copyWith(
                        fontSize: defaultSize * .75,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                if (hymns != null && hymns.isNotEmpty)
                  ...hymns.map(
                    (hymn) {
                      final isSelected = _selectedHymnIds.contains(hymn.id);
                      return ListTile(
                        leading: CircleAvatar(
                          radius: defaultSize * 0.6,
                          backgroundColor: isSelected
                              ? colorScheme.primary
                              : colorScheme.surfaceContainerHigh,
                          child: Text(
                            '${hymn.number}',
                            style: GoogleFonts.notoSans(
                              fontSize: defaultSize * 0.6,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                            ),
                          ),
                        ),
                        title: Text(
                          hymn.title,
                          style: GoogleFonts.notoSans(
                            fontSize: defaultSize * 0.75,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        trailing: Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.circle_outlined,
                          color: isSelected
                              ? colorScheme.primary
                              : colorScheme.onSurface.withAlpha(150),
                        ),
                        onTap: () => _toggleHymnSelection(hymn.id!),
                        selected: isSelected,
                        selectedTileColor: colorScheme.primary.withAlpha(150),
                      );
                    },
                  ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(defaultSize),
      child: ElevatedButton(
        onPressed: _selectedHymnIds.isNotEmpty ? _addSelectedHymns : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultSize * 0.5),
          ),
          padding: EdgeInsets.symmetric(vertical: defaultSize * 0.75),
          minimumSize: Size(double.infinity, 0),
        ),
        child: Text(
          l10n.addToCollection(_selectedHymnIds.length),
          style: GoogleFonts.notoSans(
            fontSize: defaultSize * 0.8,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final vh = SizeConfig.vh;
    final colorScheme = Theme.of(context).colorScheme;

    return DismissibleKeyboard(
      child: Container(
        height: vh * 0.8,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(defaultSize),
          ),
        ),
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchBar(context),
            Expanded(
              child: _buildHymnList(context),
            ),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }
}
