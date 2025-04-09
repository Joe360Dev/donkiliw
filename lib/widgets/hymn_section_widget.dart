import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/section.dart';
import 'package:hymns/utils/size_config.dart';

class HymnSectionWidget extends StatelessWidget {
  const HymnSectionWidget({
    super.key,
    required this.section,
    this.fontSize = 16.0,
    this.isMultiTitle = false,
  });

  final Section section;
  final double fontSize;
  final bool isMultiTitle;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final bool isRefrain = section.sectionType == 'refrain';

    if (section.sectionType == 'title') {
      return isMultiTitle
          ? Padding(
              padding: EdgeInsets.only(
                top: section.sequence == 1 ? 0 : defaultSize * .25,
                bottom: defaultSize * .5,
              ),
              child: Text(
                section.phrases.first.content,
                style: textTheme.titleLarge!.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Container();
    }

    return Container(
      margin: EdgeInsets.only(
        left: isRefrain ? defaultSize * .75 : 0,
        bottom: defaultSize,
      ),
      padding: EdgeInsets.only(
        left: isRefrain ? defaultSize * .5 : 0,
      ),
      decoration: BoxDecoration(
        border: Border(
          left: isRefrain
              ? BorderSide(
                  color: colorScheme.secondary,
                  width: defaultSize * .25,
                )
              : BorderSide.none,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...List.generate(section.phrases.length, (index) {
            final phrase = section.phrases[index];
            return RichText(
              text: TextSpan(
                text: phrase.content,
                style: GoogleFonts.notoSans(
                  fontSize: fontSize,
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.normal,
                  height: 1.5,
                ),
                children: [
                  if (phrase.repeatCount > 1)
                    TextSpan(
                      text: ' (${phrase.repeatCount}x)',
                      style: GoogleFonts.notoSans(
                        fontSize: fontSize * .9,
                        color: colorScheme.onSurface,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
