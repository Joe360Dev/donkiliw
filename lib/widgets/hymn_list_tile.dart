import 'package:donkiliw/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/models/hymn.dart';
import 'package:donkiliw/pages/hymn_page.dart';
import 'package:donkiliw/utils/size_config.dart';

class HymnListTile extends StatelessWidget {
  const HymnListTile({
    super.key,
    required this.hymn,
    required this.contextHymns,
    this.onActionTap,
  });

  final Hymn hymn;
  final List<Hymn> contextHymns;
  final Function()? onActionTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return ListTile(
      onTap: () async {
        await Navigator.of(context).pushNamed(
          HymnPage.routeName,
          arguments: {
            'initial_index': contextHymns.indexWhere(
              (hmn) => hmn.id == hymn.id,
            ),
            'context_hymns': contextHymns,
          },
        );
        onActionTap?.call(); // Refresh parent if possible
      },
      contentPadding: EdgeInsets.only(
        left: defaultSize * .5,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          defaultSize * .25,
        ),
      ),
      leading: Container(
        height: defaultSize * 2,
        width: defaultSize * 2.1,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            defaultSize * .15,
          ),
          border: Border.all(
            color: colorScheme.outlineVariant,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          hymn.number.toString(),
          style: GoogleFonts.notoSans(
            color: colorScheme.primary,
            fontWeight: FontWeight.w600,
            fontSize: defaultSize * .8,
          ),
        ),
      ),
      title: Text(
        hymn.title,
        style: GoogleFonts.notoSans(
          fontSize: defaultSize * .8,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
      ),
      subtitle: Text(
        hymn.firstLine ?? '${hymn.bookName ?? l10n.hymn} No. ${hymn.number}',
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.notoSans(
          textStyle: textTheme.titleSmall!.copyWith(
            fontWeight: FontWeight.normal,
          ),
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.more_horiz_rounded,
          size: defaultSize,
          color: colorScheme.secondary.withAlpha(150),
        ),
        onPressed: onActionTap,
      ),
    );
  }
}
