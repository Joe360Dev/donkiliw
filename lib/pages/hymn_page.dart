import 'package:donkiliw/models/hymn.dart';
import 'package:donkiliw/models/section.dart';
import 'package:donkiliw/providers/settings_provider.dart';
import 'package:donkiliw/utils/database_helper.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/future_builder_wrapper.dart';
import 'package:donkiliw/widgets/hymn_actions_bottom_sheet.dart';
import 'package:donkiliw/widgets/hymn_section_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
  late int _currentIndex; // This now refers to the group index
  double _fontSize = 16.0;
  late PageController _pageController;
  late List<List<Hymn>> _groupedHymns;
  late Future<List<Hymn>> _groupFuture;

  @override
  void initState() {
    super.initState();

    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _fontSize = settings.fontSize;

    _groupHymns();
    _loadGroupData();
  }

  void _groupHymns() {
    _groupedHymns = [];
    if (widget.contextHymns.isEmpty) return;

    List<Hymn> currentGroup = [];
    int initialFlatIndex = widget.initialIndex;
    Hymn targetHymn = widget.contextHymns[initialFlatIndex];
    int? targetGroupIndex;

    for (int i = 0; i < widget.contextHymns.length; i++) {
      final h = widget.contextHymns[i];
      if (currentGroup.isEmpty ||
          (h.number == currentGroup.last.number &&
              h.hymnBookId == currentGroup.last.hymnBookId)) {
        currentGroup.add(h);
      } else {
        _groupedHymns.add(currentGroup);
        currentGroup = [h];
      }

      if (h.id == targetHymn.id) {
        targetGroupIndex = _groupedHymns.length;
      }
    }
    if (currentGroup.isNotEmpty) {
      _groupedHymns.add(currentGroup);
      targetGroupIndex ??= _groupedHymns.length - 1;
    }

    _currentIndex = targetGroupIndex ?? 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _loadGroupData() {
    final dbHelper = DatabaseHelper();
    final group = _groupedHymns[_currentIndex];

    // We fetch full data for all hymns in the group
    _groupFuture = Future.wait(group.map((h) => dbHelper.getHymnData(h.id!)));
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

  void _showBottomSheet(BuildContext ctx, Hymn hymn) {
    HymnActionsBottomSheet.show(ctx, hymn, onUpdate: () {
      setState(() {}); // Refresh UI state (isLiked icon)
    });
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<List<Hymn>>(
          future: _groupFuture,
          builder: (context, snapshot) {
            String title = "";
            if (snapshot.hasData) {
              title = snapshot.data!.map((h) => h.title).join(" / ");
            } else {
              title = _groupedHymns[_currentIndex].first.title;
            }
            return Text(
              title,
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
          child: FutureBuilder<List<Hymn>>(
            future: _groupFuture,
            builder: (context, snapshot) {
              final group = snapshot.data ?? _groupedHymns[_currentIndex];
              final hymn = group.first;
              final anyLiked = group.any((h) => h.isLiked);
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
                  if (anyLiked) ...[
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
        controller: _pageController,
        itemCount: _groupedHymns.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _loadGroupData();
          });
        },
        itemBuilder: (context, index) {
          return FutureBuilderWrapper<List<Hymn>>(
            future: _groupFuture,
            builder: (group) {
              return ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: defaultSize,
                  vertical: defaultSize * .5,
                ),
                itemCount: group.length,
                itemBuilder: (context, idx) {
                  final hymn = group[idx];
                  final List<Section> sections = _getHymnSections(hymn);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (group.length > 1)
                        Padding(
                          padding: EdgeInsets.only(
                            bottom: defaultSize * .5,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Text(
                                  hymn.title,
                                  style: GoogleFonts.notoSans(
                                    fontSize: defaultSize * .9,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: defaultSize * .25),
                              InkWell(
                                onTap: () {
                                  _showBottomSheet(context, hymn);
                                },
                                child: Icon(
                                  Icons.more_horiz_rounded,
                                  size: defaultSize,
                                  color: colorScheme.secondary.withAlpha(200),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ...sections.map(
                        (section) => HymnSectionWidget(
                          section: section,
                          fontSize: _fontSize,
                          isMultiTitle: hymn.isMutiTitle,
                        ),
                      ),
                      if (idx < group.length - 1)
                        const Divider(
                          height: 32,
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FutureBuilder<List<Hymn>>(
        future: _groupFuture,
        builder: (context, snapshot) {
          final group = snapshot.data ?? _groupedHymns[_currentIndex];
          if (group.length > 1) return const SizedBox.shrink();

          final hymn = group.first;
          return FloatingActionButton(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            onPressed: () {
              _showBottomSheet(context, hymn);
            },
            child: const Icon(
              Icons.more_horiz_rounded,
            ),
          );
        },
      ),
    );
  }
}
