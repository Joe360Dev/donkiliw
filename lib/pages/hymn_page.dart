import 'dart:io';
import 'dart:typed_data';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/models/section.dart';
import 'package:hymns/utils/database_helper.dart';
import 'package:hymns/providers/settings_provider.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/add_hymn_to_collection_bottom_sheet.dart';
import 'package:hymns/widgets/circular_icon_text_button.dart';
import 'package:hymns/widgets/future_builder_wrapper.dart';
import 'package:hymns/widgets/hymn_section_widget.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';

class HymnPage extends StatefulWidget {
  const HymnPage({
    super.key,
    required this.contextHymns,
    required this.initialIndex,
  });

  final List<Hymn> contextHymns;
  final int initialIndex;

  static const routeName = '/hymn';

  @override
  State<HymnPage> createState() => _HymnPageState();
}

class _HymnPageState extends State<HymnPage> {
  late int _currentIndex;
  double _fontSize = 16.0;
  late PageController _pageController;
  late ValueNotifier<Hymn> _currentHymnNotifier;
  late Future<Hymn> _hymnFuture;
  late List<Section> _sections;
  final _screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _fontSize = settings.fontSize;
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: _currentIndex);
    _currentHymnNotifier = ValueNotifier(widget.contextHymns[_currentIndex]);
    _loadHymnData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadHymnData() {
    final dbHelper = DatabaseHelper();
    _hymnFuture =
        dbHelper.getHymnData(widget.contextHymns[_currentIndex].id!).then(
      (hymn) {
        _currentHymnNotifier.value = hymn;
        _sections = _getHymnSections(hymn);
        return hymn;
      },
    );
  }

  List<Section> _getHymnSections(Hymn hymn) {
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    final List<Section> sections = [];

    for (final section in hymn.sections) {
      final Section? refrainSection =
          hymn.sections.where((s) => s.sectionType == 'refrain').firstOrNull;
      Section? previousSection = refrainSection;

      if (!settings.repeatRefrain || (previousSection?.id != section.id)) {
        sections.add(section);
        previousSection = section;
      }

      if (refrainSection != null &&
          settings.repeatRefrain &&
          !hymn.isMultipleRefrain &&
          section.sectionType == 'verse') {
        sections.add(refrainSection);
      }
    }

    return sections;
  }

  void _showBottomSheet(BuildContext ctx) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(ctx);
    final defaultSize = SizeConfig.defaultSize;
    final vh = SizeConfig.vh;
    final hymn = _currentHymnNotifier.value;

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
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircularIconTextButton(
                  icon: hymn.isLiked ? Icons.favorite : Icons.favorite_border,
                  title: l10n.favorites,
                  onPressed: () {
                    _toggleLike();
                    Navigator.of(ctx).pop();
                  },
                ),
                CircularIconTextButton(
                  icon: Icons.bookmark_add_outlined,
                  title: l10n.collection,
                  onPressed: () {
                    _showAddHymnToCollectionBottomSheet(
                      context,
                      hymn.id!,
                    );
                  },
                ),
                CircularIconTextButton(
                  icon: Icons.share,
                  title: l10n.share,
                  onPressed: () {
                    _shareLyrics(hymn);
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            ),
            SizedBox(height: defaultSize * .5),
            Divider(height: defaultSize * .5),
            Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: defaultSize * 1.5,
                  ),
                  onTap: () {
                    _copyLyrics(hymn, ctx);
                    Navigator.of(ctx).pop();
                  },
                  title: Text(
                    l10n.copy,
                    style: GoogleFonts.notoSans(
                      fontSize: defaultSize * .8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.copy),
                ),
                Divider(height: defaultSize * .5),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: defaultSize * 1.5,
                  ),
                  onTap: () {
                    _exportLyricsAsImage(hymn);
                    Navigator.of(ctx).pop();
                  },
                  title: Text(
                    l10n.exportAsImage,
                    style: GoogleFonts.notoSans(
                      fontSize: defaultSize * .8,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: Icon(Icons.image),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  void _toggleLike() async {
    final l10n = AppLocalizations.of(context)!;
    final dbHelper = DatabaseHelper();
    final hymn = _currentHymnNotifier.value;

    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    _currentHymnNotifier.value = _currentHymnNotifier.value.copyWith(
      isLiked: !hymn.isLiked,
    );

    try {
      await dbHelper.toggleHymnLike(hymn);
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.toggleLikeResponseMessage(
            hymn.isLiked ? 'unliked' : 'liked',
          ),
          style: textTheme.titleMedium!.copyWith(
            fontSize: defaultSize * .85,
            fontWeight: FontWeight.w500,
            color: colorScheme.surface,
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
    } catch (e) {
      _currentHymnNotifier.value = hymn.copyWith(
        isLiked: hymn.isLiked,
      );
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
        icon: const Icon(Icons.error),
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

    // Sync with database
    // _loadHymnData();
  }

  void _showAddHymnToCollectionBottomSheet(BuildContext ctx, int hymnId) async {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AddHymnToCollectionBottomSheet(
          hymnId: hymnId,
        );
      },
    ).then((result) {
      if (result != null && result > 0) {}
    });
  }

  void _shareLyrics(Hymn hymn) async {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final lyrics = _getHymnLyrics(hymn);
    final shareText = '${l10n.title}: ${hymn.title}\n'
        '${l10n.book}: ${hymn.bookName ?? "-"}\n'
        '${l10n.number}: ${hymn.number}\n\n'
        '$lyrics';
    await Share.share(
      shareText,
      subject: hymn.title,
    );
    toastification.show(
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(
        l10n.hymnShared,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: colorScheme.surface,
        ),
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

  void _copyLyrics(Hymn hymn, BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final lyrics = '${l10n.title}: ${hymn.title}\n'
        '${l10n.book}: ${hymn.bookName ?? "-"}\n'
        '${l10n.number}: ${hymn.number}\n\n'
        '${_getHymnLyrics(hymn)}';

    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    FlutterClipboard.copy(lyrics).then((_) {
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.hymnCopied,
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
    }).catchError((error) {
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.errorWhenCopying,
          style: textTheme.titleMedium!.copyWith(
            color: colorScheme.surface,
            fontSize: defaultSize * .85,
            fontWeight: FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        alignment: Alignment.bottomCenter,
        icon: const Icon(Icons.error),
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
    });
  }

  String _getHymnLyrics(Hymn hymn) {
    final buffer = StringBuffer();
    for (var section in hymn.sections) {
      if (section.id != hymn.sections.first.id &&
          section.title != null &&
          section.title!.isNotEmpty) {
        buffer.writeln('${section.title}:');
      }
      for (var phrase in section.phrases) {
        buffer.writeln(phrase.content);
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }

  String _formatDoubleDigit(int number) {
    return number.toString().padLeft(2, '0');
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    final year = now.year.toString();
    final month = _formatDoubleDigit(now.month);
    final day = _formatDoubleDigit(now.day);
    return '$year$month$day';
  }

  Future<bool> _requestPermissions(BuildContext context) async {
    try {
      if (Platform.isAndroid) {
        return await _handleAndroidPermissions(context);
      } else if (Platform.isIOS) {
        return await _handleIosPermissions(context);
      }
      return true;
    } catch (e) {
      debugPrint('Permission request error: $e');
      return false;
    }
  }

  Future<bool> _handleAndroidPermissions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    final sdkInt = androidInfo.version.sdkInt;

    // Android 13+ (API 33+) uses READ_MEDIA_IMAGES
    // Below uses WRITE_EXTERNAL_STORAGE (deprecated in API 33)
    final permission = sdkInt >= 33 ? Permission.photos : Permission.storage;
    final permissionName =
        sdkInt >= 33 ? l10n.photosPermission : l10n.storagePermission;

    var status = await permission.status;

    if (status.isGranted) return true;
    if (status.isDenied) {
      status = await permission.request();
    }

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      return await _showPermanentlyDeniedDialog(context, permissionName);
    }

    return await _showDeniedDialog(context, permissionName, permission);
  }

  Future<bool> _handleIosPermissions(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    var status = await Permission.photosAddOnly.status;
    final permissionName = l10n.photosPermission;

    if (status.isGranted) {
      return true;
    }
    if (status.isDenied) {
      status = await Permission.photosAddOnly.request();
    }

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied || status.isRestricted) {
      return await _showPermanentlyDeniedDialog(
        context,
        permissionName,
      );
    }

    return await _showDeniedDialog(
      context,
      permissionName,
      Permission.photosAddOnly,
    );
  }

  Future<bool> _showPermanentlyDeniedDialog(
    BuildContext context,
    String permissionName,
  ) async {
    final defaultSize = SizeConfig.defaultSize;
    final l10n = AppLocalizations.of(context)!;
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionRequired),
        content: Text(
          l10n.permissionRequiredMessage(
            permissionName,
            l10n.saveHymnImages,
          ),
          style: GoogleFonts.notoSans(
            fontSize: defaultSize * .7,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.openSettings),
          ),
        ],
      ),
    );

    if (shouldOpenSettings == true) {
      await openAppSettings();
    }
    return false;
  }

  Future<bool> _showDeniedDialog(
    BuildContext context,
    String permissionName,
    Permission permission,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    final shouldRetry = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.permissionDenied),
        content: Text(
          l10n.permissionDeniedMessage(
            permissionName,
            l10n.saveHymnImages,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );

    // Handle null case (e.g., dialog dismissed with back button)
    if (shouldRetry != true) return false;

    // Re-request the specific permission instead of recursive call
    final status = await permission.request();
    if (status.isGranted || (Platform.isIOS && status.isLimited)) {
      return true;
    }

    // If still denied, show the dialog again (or permanently denied dialog if applicable)
    if (status.isPermanentlyDenied || (Platform.isIOS && status.isRestricted)) {
      return await _showPermanentlyDeniedDialog(context, permissionName);
    }
    return false;
  }

  double _getExportWidgetHeight() {
    final defaultSize = SizeConfig.defaultSize;
    final sections = _sections;

    double height = 0;

    // AppBar height (title + bottom)
    // Standard AppBar + PreferredSize
    height += kToolbarHeight + (defaultSize * 0.8);

    // Top spacing in body
    height += 8.0; // SizedBox(height: 8)
    // body padding

    // Sections and phrases
    for (var section in sections) {
      final isRefrain = section.sectionType == 'refrain';

      // Each phrase height: fontSize * lineHeight (1.5) + padding
      double phraseHeight = _fontSize * 1.5; // Base height per line
      // Account for repeat count text (inline, no extra height unless wrapped)
      // Assuming no wrapping for simplicity; adjust if phrases wrap significantly
      height += section.phrases.length * phraseHeight;

      // Section padding and margin
      height += defaultSize; // margin.bottom
      if (isRefrain) {
        // padding.left doesn’t affect height, but included for consistency
        height += defaultSize * 0.5;
      }
    }

    // Bottom spacing and signature
    height += defaultSize; // SizedBox(height: 16)
    height += defaultSize * 0.8 + _fontSize * 1.2;

    // Safety margin
    height += 20.0;

    return height;
  }

  Future<void> _exportLyricsAsImage(Hymn hymn) async {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final mediaQueryData = MediaQuery.of(context);
    final packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;

    try {
      final hasPermission = await _requestPermissions(context);
      if (!hasPermission) {
        toastification.show(
          context: context,
          type: ToastificationType.error,
          style: ToastificationStyle.flat,
          title: Text(
            l10n.permissionDenied,
            style: textTheme.titleMedium!.copyWith(
              color: colorScheme.surface,
              fontWeight: FontWeight.w500,
            ),
          ),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.error),
          showIcon: true,
          primaryColor: colorScheme.inversePrimary,
          backgroundColor: colorScheme.inverseSurface,
          foregroundColor: colorScheme.inversePrimary,
          closeOnClick: true,
          pauseOnHover: true,
          dragToClose: true,
          closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
          autoCloseDuration: const Duration(seconds: 2),
        );
        return;
      }

      final exportWidget = MediaQuery(
        data: mediaQueryData,
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: Theme.of(context),
          home: Scaffold(
            appBar: AppBar(
              title: Text(
                hymn.title,
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.bold,
                  fontSize: defaultSize,
                  textStyle: textTheme.titleMedium,
                ),
              ),
              backgroundColor: Colors.transparent,
              elevation: 0,
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(defaultSize * 0.8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${hymn.bookName} No. ${hymn.number}',
                      style: GoogleFonts.notoSans(
                        fontSize: defaultSize * 0.9,
                        fontWeight: FontWeight.w500,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: defaultSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  ..._sections
                      .where((section) =>
                          section.sequence != 1 &&
                          section.sectionType != 'title')
                      .map(
                        (section) => HymnSectionWidget(
                          section: section,
                          fontSize: _fontSize,
                        ),
                      ),
                  Divider(
                    color: colorScheme.onSurface,
                    thickness: 1,
                    height: defaultSize,
                  ),
                  Text(
                    l10n.signature(appName),
                    style: TextStyle(
                      fontSize: defaultSize * 0.8,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final image = await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(context, exportWidget),
        constraints: BoxConstraints(
          maxWidth: mediaQueryData.size.width,
          maxHeight: _getExportWidgetHeight(),
        ),
        pixelRatio: 2,
      );

      final formattedDate = _getFormattedDate();
      final fileName = '${hymn.title.replaceAll(' ', '_')}_$formattedDate.png';

      final result = await ImageGallerySaverPlus.saveImage(
        image,
        quality: 100,
        name: fileName,
      );

      if (result['isSuccess'] == true) {
        toastification.show(
          context: context,
          type: ToastificationType.success,
          style: ToastificationStyle.flat,
          title: Text(
            l10n.imageSavedToGallery,
            style: textTheme.titleMedium!.copyWith(
              color: colorScheme.surface,
              fontWeight: FontWeight.w500,
            ),
          ),
          alignment: Alignment.bottomCenter,
          icon: const Icon(Icons.check),
          showIcon: true,
          primaryColor: colorScheme.primary,
          backgroundColor: colorScheme.surface,
          foregroundColor: colorScheme.onSurface,
          autoCloseDuration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Failed to save image: ${result['errorMessage']}');
      }
    } catch (e) {
      toastification.show(
        context: context,
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.imageExportationFailedMessage,
          style: textTheme.titleMedium!.copyWith(
            color: colorScheme.surface,
            fontWeight: FontWeight.w500,
          ),
        ),
        alignment: Alignment.bottomCenter,
        icon: const Icon(Icons.error),
        showIcon: true,
        primaryColor: colorScheme.inversePrimary,
        backgroundColor: colorScheme.inverseSurface,
        foregroundColor: colorScheme.inversePrimary,
        closeOnClick: true,
        pauseOnHover: true,
        dragToClose: true,
        closeButton: ToastCloseButton(showType: CloseButtonShowType.none),
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<Hymn>(
          valueListenable: _currentHymnNotifier,
          builder: (context, value, child) {
            return Text(
              _currentHymnNotifier.value.title,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: GoogleFonts.notoSans(
                fontWeight: FontWeight.bold,
                fontSize: defaultSize,
                textStyle: textTheme.titleMedium,
              ),
            );
          },
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _fontSize = _fontSize < 28 ? _fontSize + 2 : 14.0;
              });
            },
            icon: Icon(
              Icons.format_size,
              size: defaultSize * 1.5,
            ),
          ),
          SizedBox(width: defaultSize * .5),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            defaultSize,
          ),
          child: ValueListenableBuilder<Hymn>(
            valueListenable: _currentHymnNotifier,
            builder: (context, hymn, _) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${hymn.bookName} No. ${hymn.number}',
                    style: GoogleFonts.notoSans(
                      fontSize: defaultSize * .9,
                      fontWeight: FontWeight.w500,
                      color: colorScheme.primary,
                    ),
                  ),
                  if (hymn.isLiked) ...[
                    SizedBox(width: defaultSize * .5),
                    Icon(
                      Icons.favorite,
                      size: defaultSize,
                      color: colorScheme.primary,
                    ),
                  ],
                ],
              );
            },
          ),
        ),
      ),
      body: PageView.builder(
        itemCount: widget.contextHymns.length,
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _loadHymnData();
          });
        },
        itemBuilder: (context, index) {
          return FutureBuilderWrapper<Hymn>(
            future: _hymnFuture,
            emptyText: l10n.noResult,
            builder: (hymn) {
              return ListView.builder(
                padding: EdgeInsets.only(
                  top: defaultSize * .5,
                  left: defaultSize,
                  right: defaultSize * .5,
                  bottom: defaultSize * 2,
                ),
                itemCount: _sections.length,
                itemBuilder: (context, sectionIndex) {
                  final section = _sections[sectionIndex];

                  return HymnSectionWidget(
                    section: section,
                    fontSize: _fontSize,
                    isMultiTitle: hymn.isMutiTitle,
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBottomSheet(context),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        child: Icon(Icons.add),
      ),
    );
  }
}
