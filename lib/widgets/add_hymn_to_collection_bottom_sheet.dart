import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn_collection.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/dismissible_keyboard.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:toastification/toastification.dart';

class AddHymnToCollectionBottomSheet extends StatefulWidget {
  const AddHymnToCollectionBottomSheet({
    super.key,
    required this.hymnId,
  });

  final int hymnId;

  @override
  State<AddHymnToCollectionBottomSheet> createState() =>
      _AddHymnToCollectionBottomSheetState();
}

class _AddHymnToCollectionBottomSheetState
    extends State<AddHymnToCollectionBottomSheet> {
  late Future<List<HymnCollection>> _collectionsFuture;
  final TextEditingController _searchController = TextEditingController();
  List<HymnCollection> _filteredCollections = [];
  final Set<int> _selectedCollectionIds = {};

  @override
  void initState() {
    super.initState();
    final dbHelper = DatabaseHelper();
    _collectionsFuture = dbHelper.getAllCollections().then((collections) {
      _filteredCollections = collections;
      return _filteredCollections;
    });
    _searchController.addListener(_filterCollections);
  }

  void _filterCollections() {
    final query = _searchController.text.toLowerCase();
    _collectionsFuture.then((allCollections) {
      setState(() {
        _filteredCollections = allCollections.where((collection) {
          return collection.title!.toLowerCase().contains(query) ||
              (collection.description ?? '').toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  Widget _buildHeader(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        vertical: defaultSize * .75,
      ),
      child: Text(
        l10n.selectionCollection,
        style: GoogleFonts.notoSans().copyWith(
          fontSize: defaultSize * 0.9,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
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
        style: GoogleFonts.notoSans().copyWith(
          fontSize: defaultSize * 0.75,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        decoration: InputDecoration(
          filled: true,
          fillColor: colorScheme.surfaceContainerLow,
          contentPadding: EdgeInsets.symmetric(
            horizontal: defaultSize,
            vertical: defaultSize * 0.5,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(defaultSize * 0.5),
            borderSide: BorderSide.none,
          ),
          hintText: l10n.searchCollection,
          hintStyle: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize * 0.75,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withAlpha(150),
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

  void _onToggleCollectionSelection(int collectionId) {
    setState(() {
      if (_selectedCollectionIds.contains(collectionId)) {
        _selectedCollectionIds.remove(collectionId);
      } else {
        _selectedCollectionIds.add(collectionId);
      }
    });
  }

  Widget _buildCollectionList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilderWrapper<List<HymnCollection>>(
      future: _collectionsFuture,
      errorText: l10n.errorWhenLoadingCollections,
      builder: (data) {
        return ListView.builder(
          itemCount: _filteredCollections.length,
          itemBuilder: (context, index) {
            final collection = _filteredCollections[index];
            final isSelected = _selectedCollectionIds.contains(collection.id);
            return ListTile(
              leading: CircleAvatar(
                radius: defaultSize * 0.75,
                backgroundColor: isSelected
                    ? colorScheme.primary
                    : colorScheme.surfaceContainer,
                child: Text(
                  '${collection.id}',
                  style: GoogleFonts.notoSans().copyWith(
                    fontSize: defaultSize * 0.6,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface,
                  ),
                ),
              ),
              title: Text(
                collection.title!,
                style: GoogleFonts.notoSans().copyWith(
                  fontSize: defaultSize * 0.75,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              subtitle: collection.description != ''
                  ? Text(
                      collection.description!,
                      style: GoogleFonts.notoSans().copyWith(
                        fontSize: defaultSize * .6,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface.withAlpha(180),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    )
                  : null,
              trailing: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected
                    ? colorScheme.primary
                    : colorScheme.onSurface.withAlpha(150),
              ),
              onTap: () => _onToggleCollectionSelection(collection.id!),
              selected: isSelected,
              selectedTileColor: colorScheme.primary.withAlpha(150),
            );
          },
        );
      },
    );
  }

  Future<void> _addHymnToSelectedCollections() async {
    final l10n = AppLocalizations.of(context)!;

    final dbHelper = DatabaseHelper();
    for (var collectionId in _selectedCollectionIds) {
      await dbHelper.addHymnToCollection(
        widget.hymnId,
        collectionId,
      );
    }

    if (mounted) {
      final defaultSize = SizeConfig.defaultSize;
      final colorScheme = Theme.of(context).colorScheme;
      final textTheme = Theme.of(context).textTheme;

      Navigator.pop(
        context,
        _selectedCollectionIds.length,
      );

      Navigator.pop(context);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.hymnsAddedToCollection(
            _selectedCollectionIds.length,
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

  Widget _buildActionButton(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(defaultSize),
      child: ElevatedButton(
        onPressed: _selectedCollectionIds.isNotEmpty
            ? _addHymnToSelectedCollections
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(defaultSize * 0.5),
          ),
          padding: EdgeInsets.symmetric(vertical: defaultSize * 0.75),
          minimumSize: Size(double.infinity, 0), // Full width
        ),
        child: Text(
          l10n.addToCollection(
            _selectedCollectionIds.length,
          ),
          style: GoogleFonts.notoSans().copyWith(
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
              child: _buildCollectionList(context),
            ),
            _buildActionButton(context),
          ],
        ),
      ),
    );
  }
}
