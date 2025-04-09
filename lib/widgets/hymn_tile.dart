import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/pages/hymn_page.dart';
import 'package:hymns/utils/size_config.dart';

class HymnTile extends StatelessWidget {
  const HymnTile({
    super.key,
    required this.hymn,
    required this.contextHymns,
  });
  final Hymn hymn;
  final List<Hymn> contextHymns;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return ListTile(
      onTap: () {
        Navigator.of(context).pushNamed(
          HymnPage.routeName,
          arguments: {
            'initial_index': contextHymns.indexWhere(
              (hmn) => hmn.id == hymn.id,
            ),
            'context_hymns': contextHymns,
          },
        );
      },
      horizontalTitleGap: defaultSize * .5,
      leading: SizedBox(
        height: defaultSize * 2,
        width: defaultSize * 2.5,
        child: OutlinedButton(
          onPressed: () {
            Navigator.of(context).pushNamed(
              HymnPage.routeName,
              arguments: {
                'initial_index': contextHymns.indexWhere(
                  (hmn) => hmn.id == hymn.id,
                ),
                'context_hymns': contextHymns,
              },
            );
          },
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.all(
              defaultSize * .25,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                defaultSize * .15,
              ),
            ),
          ),
          child: Text(
            hymn.number.toString(),
            style: GoogleFonts.notoSans().copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
              fontSize: textTheme.bodyMedium!.fontSize,
            ),
          ),
        ),
      ),
      title: Text(
        hymn.title,
        style: GoogleFonts.notoSans().copyWith(
          color: colorScheme.primary,
          fontSize: textTheme.bodyLarge!.fontSize,
        ),
      ),
    );
  }
}
