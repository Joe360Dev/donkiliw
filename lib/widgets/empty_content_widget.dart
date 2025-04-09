import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hymns/utils/size_config.dart';

class EmptyContentWidget extends StatelessWidget {
  const EmptyContentWidget({
    super.key,
    required this.emptyText,
  });

  final String? emptyText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(defaultSize),
        child: Text(
          emptyText ?? l10n.emptyText,
          style: GoogleFonts.notoSans().copyWith(
            fontSize: defaultSize * 0.75,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurface.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
