import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:donkiliw/l10n/app_localizations.dart';
import 'package:donkiliw/models/hymn.dart';
import 'package:donkiliw/utils/database_helper.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/add_hymn_to_collection_bottom_sheet.dart';
import 'package:donkiliw/widgets/circular_icon_text_button.dart';
import 'package:donkiliw/widgets/hymn_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toastification/toastification.dart';
import 'package:clipboard/clipboard.dart';

class HymnActionsBottomSheet extends StatefulWidget {
  final Hymn hymn;
  final VoidCallback? onUpdate;

  const HymnActionsBottomSheet({
    super.key,
    required this.hymn,
    this.onUpdate,
  });

  @override
  State<HymnActionsBottomSheet> createState() => _HymnActionsBottomSheetState();

  static void show(BuildContext context, Hymn hymn, {VoidCallback? onUpdate}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(SizeConfig.defaultSize),
        ),
      ),
      builder: (context) => HymnActionsBottomSheet(
        hymn: hymn,
        onUpdate: onUpdate,
      ),
    );
  }
}

class _HymnActionsBottomSheetState extends State<HymnActionsBottomSheet> {
  final _screenshotController = ScreenshotController();

  Future<void> _toggleLike() async {
    final l10n = AppLocalizations.of(context)!;
    final dbHelper = DatabaseHelper();
    final originallyLiked = widget.hymn.isLiked;

    setState(() {
      widget.hymn.isLiked = !originallyLiked;
    });

    try {
      await dbHelper.toggleHymnLike(widget.hymn.id!, originallyLiked);
      widget.onUpdate?.call();

      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(
          l10n.toggleLikeResponseMessage(
            widget.hymn.isLiked ? 'liked' : 'unliked',
          ),
          style: TextStyle(
            fontSize: SizeConfig.defaultSize * .85,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).colorScheme.surface,
          ),
        ),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
      );
    } catch (e) {
      setState(() {
        widget.hymn.isLiked = originallyLiked;
      });
      toastification.show(
        type: ToastificationType.error,
        style: ToastificationStyle.flat,
        title: Text(l10n.errorTryAgain),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
      );
    }
  }

  void _showAddHymnToCollection() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          AddHymnToCollectionBottomSheet(hymnId: widget.hymn.id!),
    );
  }

  void _copyLyrics() {
    final l10n = AppLocalizations.of(context)!;
    final lyrics = '${l10n.title}: ${widget.hymn.title}\n'
        '${l10n.book}: ${widget.hymn.bookName ?? "-"}\n'
        '${l10n.number}: ${widget.hymn.number}\n\n'
        '${_getHymnLyricsText()}';

    FlutterClipboard.copy(lyrics).then((_) {
      toastification.show(
        type: ToastificationType.success,
        style: ToastificationStyle.flat,
        title: Text(l10n.hymnCopied),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 2),
      );
    });
    Navigator.of(context).pop();
  }

  String _getHymnLyricsText() {
    final buffer = StringBuffer();
    for (var section in widget.hymn.sections) {
      if (section.title != null && section.title!.isNotEmpty) {
        buffer.writeln('${section.title}:');
      }
      for (var phrase in section.phrases) {
        buffer.writeln(phrase.content);
      }
      buffer.writeln();
    }
    return buffer.toString().trim();
  }

  void _shareLyrics() async {
    final l10n = AppLocalizations.of(context)!;
    final shareText = '${l10n.title}: ${widget.hymn.title}\n'
        '${l10n.book}: ${widget.hymn.bookName ?? "-"}\n'
        '${l10n.number}: ${widget.hymn.number}\n\n'
        '${_getHymnLyricsText()}';

    await SharePlus.instance.share(
      ShareParams(
        title: widget.hymn.title,
        text: shareText,
        subject: widget.hymn.title,
      ),
    );
    Navigator.of(context).pop();
  }

  Future<void> _exportLyricsAsImage() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final vw = MediaQuery.of(context).size.width;
    final packageInfo = await PackageInfo.fromPlatform();
    final appName = packageInfo.appName;
    final colorScheme = theme.colorScheme;
    final defaultSize = SizeConfig.defaultSize;

    try {
      final hasPermission = await _requestPermissions();
      if (!hasPermission) {
        toastification.show(
          type: ToastificationType.error,
          title: Text(l10n.permissionDenied),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 3),
        );
        return;
      }

      // Show loading indicator
      toastification.show(
        type: ToastificationType.info,
        title: Text(l10n.generatingImage),
        alignment: Alignment.bottomCenter,
      );

      final exportWidget = Material(
        color: colorScheme.surface,
        child: Container(
          width: vw,
          padding: EdgeInsets.all(defaultSize),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.hymn.title,
                style: GoogleFonts.notoSans(
                  fontWeight: FontWeight.bold,
                  fontSize: defaultSize * 1.2,
                  color: colorScheme.primary,
                ),
              ),
              Text(
                '${widget.hymn.bookName} No. ${widget.hymn.number}',
                style: GoogleFonts.notoSans(
                  fontSize: defaultSize * 0.9,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.secondary,
                ),
              ),
              SizedBox(height: defaultSize),
              ...widget.hymn.sections
                  .where((s) => s.sectionType != 'title')
                  .map((s) => HymnSectionWidget(
                        section: s,
                        fontSize: 16,
                      )),
              const Divider(),
              SizedBox(height: defaultSize * 0.5),
              Text(
                l10n.signature(appName),
                style: GoogleFonts.notoSans(
                  fontSize: defaultSize * 0.7,
                  color: colorScheme.onSurface.withAlpha(120),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      );

      final image = await _screenshotController.captureFromLongWidget(
        InheritedTheme.captureAll(context, exportWidget),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
        ),
        pixelRatio: 3.0, // Higher quality
      );

      final fileName =
          '${widget.hymn.title.replaceAll(RegExp(r'[^\w]'), '_')}_${DateTime.now().millisecondsSinceEpoch}.png';

      final result = await ImageGallerySaverPlus.saveImage(
        image,
        quality: 100,
        name: fileName,
      );

      toastification.dismissAll();

      if (result != null && result['isSuccess'] == true) {
        toastification.show(
          type: ToastificationType.success,
          title: Text(l10n.imageSavedToGallery),
          alignment: Alignment.bottomCenter,
          autoCloseDuration: const Duration(seconds: 3),
        );
      } else {
        throw Exception(result?['errorMessage'] ?? 'Unknown saving error');
      }
    } catch (e) {
      debugPrint('Export Error: $e');
      toastification.dismissAll();
      toastification.show(
        type: ToastificationType.error,
        title: Text(l10n.imageExportationFailedMessage),
        description: Text(e.toString()),
        alignment: Alignment.bottomCenter,
        autoCloseDuration: const Duration(seconds: 5),
      );
    }
    if (mounted) Navigator.of(context).pop();
  }

  Future<bool> _requestPermissions() async {
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;
      if (info.version.sdkInt >= 33) {
        final status = await Permission.photos.request();
        return status.isGranted || status.isLimited;
      } else {
        final status = await Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // For iOS, check if we're on simulator
      // Simulators often fail the explicit request but might still allow saving.
      // However, we'll try the standard request first.
      var status = await Permission.photosAddOnly.status;
      if (status.isDenied) {
        status = await Permission.photosAddOnly.request();
      }

      if (status.isPermanentlyDenied) {
        // Option to open settings
        return false;
      }

      return status.isGranted || status.isLimited;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final defaultSize = SizeConfig.defaultSize;

    return ListView(
      shrinkWrap: true,
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + defaultSize),
      children: [
        Padding(
          padding: EdgeInsets.all(defaultSize * 0.5),
          child: Text(
            widget.hymn.title,
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSans(
                fontWeight: FontWeight.w600, fontSize: defaultSize * 0.9),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CircularIconTextButton(
              icon:
                  widget.hymn.isLiked ? Icons.favorite : Icons.favorite_border,
              title: l10n.favorites,
              onPressed: _toggleLike,
            ),
            CircularIconTextButton(
              icon: Icons.bookmark_add_outlined,
              title: l10n.collection,
              onPressed: _showAddHymnToCollection,
            ),
            CircularIconTextButton(
              icon: Icons.share,
              title: l10n.share,
              onPressed: _shareLyrics,
            ),
          ],
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.copy),
          title: Text(l10n.copy),
          onTap: _copyLyrics,
        ),
        ListTile(
          leading: const Icon(Icons.image),
          title: Text(l10n.exportAsImage),
          onTap: _exportLyricsAsImage,
        ),
      ],
    );
  }
}
