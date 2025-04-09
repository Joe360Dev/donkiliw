import 'package:flutter/material.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/models/section.dart';
import 'package:hymns/utils/size_config.dart';
import 'package:hymns/widgets/hymn_section_widget.dart';

class HymBodyWidget extends StatelessWidget {
  const HymBodyWidget({
    super.key,
    required this.hymn,
    required this.fontSize,
    this.repeatRefrain = true,
  });

  final Hymn hymn;
  final double fontSize;
  final bool repeatRefrain;

  List<Section> _buildSections(Hymn hymn, BuildContext context) {
    final List<Section> sections = [];

    for (final section in hymn.sections) {
      final Section? refrainSection =
          hymn.sections.where((s) => s.sectionType == 'refrain').firstOrNull;
      Section? previousSection = refrainSection;

      if (repeatRefrain || (previousSection?.id != section.id)) {
        sections.add(section);
        previousSection = section;
      }

      if (refrainSection != null &&
          repeatRefrain &&
          !hymn.isMultipleRefrain &&
          section.sectionType == 'verse') {
        sections.add(refrainSection);
      }
    }

    return sections;
  }

  @override
  Widget build(BuildContext context) {
    final defaultSize = SizeConfig.defaultSize;
    final sections = _buildSections(hymn, context);

    return ListView.builder(
      padding: EdgeInsets.only(
        top: defaultSize * .5,
        left: defaultSize,
        right: defaultSize * .5,
        bottom: defaultSize * 2,
      ),
      itemCount: sections.length,
      itemBuilder: (context, sectionIndex) {
        final section = sections[sectionIndex];
        if (section.sequence == 1 && section.sectionType == 'title') {
          return Container();
        }
        return HymnSectionWidget(
          section: section,
          fontSize: fontSize,
        );
      },
    );
  }
}
