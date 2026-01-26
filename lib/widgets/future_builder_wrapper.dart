import 'package:donkiliw/l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/widgets/empty_content_widget.dart';

class FutureBuilderWrapper<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(T data) builder;
  final String? loadingText;
  final String? errorText;
  final String? emptyText;
  final bool dense;

  const FutureBuilderWrapper({
    super.key,
    required this.future,
    required this.builder,
    this.dense = false,
    this.loadingText,
    this.errorText,
    this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                ),
                if (!dense) ...[
                  SizedBox(height: defaultSize * 0.5),
                  Text(
                    loadingText ?? l10n.loadingText,
                    style: GoogleFonts.notoSans().copyWith(
                      fontSize: defaultSize * 0.75,
                      fontWeight: FontWeight.w500,
                      color:
                          colorScheme.onSurface.withAlpha(245),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(defaultSize),
              child: Text(
                errorText ?? l10n.errorText,
                style: GoogleFonts.notoSans().copyWith(
                  fontSize: defaultSize * 0.75,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final data = snapshot.data;
        if (data == null || (data is List && (data).isEmpty)) {
          return EmptyContentWidget(
            emptyText: emptyText ?? l10n.emptyText,
          );
        }
        return builder(data);
      },
    );
  }
}
