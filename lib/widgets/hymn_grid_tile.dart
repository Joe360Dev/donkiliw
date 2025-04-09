import 'package:flutter/material.dart';
import 'package:hymns/models/hymn.dart';
import 'package:hymns/pages/hymn_page.dart';
import 'package:hymns/utils/size_config.dart';

class HymnGridTile extends StatelessWidget {
  const HymnGridTile({
    super.key,
    required this.hymn,
    required this.contextHymns,
  });

  final Hymn hymn;
  final List<Hymn> contextHymns;

  @override
  Widget build(BuildContext context) {
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GridTile(
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(defaultSize * 0.25),
        child: Ink(
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(
              defaultSize * 0.25,
            ),
          ),
          child: InkWell(
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
            borderRadius: BorderRadius.circular(
              defaultSize * 0.25,
            ),
            splashColor: colorScheme.primary.withAlpha(77),
            highlightColor: colorScheme.primary.withAlpha(26),
            hoverColor: colorScheme.primary.withAlpha(20),
            child: Center(
              child: Text(
                hymn.number.toString(),
                style: textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: defaultSize * 0.9,
                  color: colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
