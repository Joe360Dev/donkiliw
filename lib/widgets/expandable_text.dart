import 'package:flutter/material.dart';
import 'package:donkiliw/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:donkiliw/utils/size_config.dart';

class ExpandableText extends StatefulWidget {
  final String? text;
  final int maxLines;
  final TextStyle? style;

  const ExpandableText({
    super.key,
    this.text,
    this.maxLines = 2,
    this.style,
  });

  @override
  State<ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<ExpandableText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final text = (widget.text != null && widget.text!.isNotEmpty)
        ? widget.text!
        : l10n.noDescription;
    final hasOverflow = _hasTextOverflow(
      text,
      widget.style,
      widget.maxLines,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          text,
          maxLines: _isExpanded ? null : widget.maxLines,
          overflow: _isExpanded ? null : TextOverflow.ellipsis,
          style: widget.style ??
              GoogleFonts.notoSans().copyWith(
                fontSize: defaultSize * 0.75,
                color: widget.text == null
                    ? colorScheme.onSurface.withAlpha(150)
                    : colorScheme.onSurface,
              ),
        ),
        if (hasOverflow)
          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            child: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(
                top: defaultSize * 0.25,
              ),
              child: Text(
                _isExpanded ? l10n.seeLess : l10n.seeMore,
                style: GoogleFonts.notoSans().copyWith(
                  fontSize: defaultSize * 0.7,
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  bool _hasTextOverflow(String text, TextStyle? style, int maxLines) {
    final vw = SizeConfig.vw;
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: vw * 0.9);
    return textPainter.didExceedMaxLines;
  }
}
