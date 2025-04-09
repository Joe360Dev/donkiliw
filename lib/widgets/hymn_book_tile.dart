import 'package:flutter/material.dart';
import 'package:hymns/pages/hymn_book_page.dart';
import 'package:hymns/utils/size_config.dart';

class HymnBookTile extends StatefulWidget {
  const HymnBookTile({
    super.key,
    required this.hymnBookId,
    required this.title,
    required this.coverImagePath,
    this.description,
  });

  final int hymnBookId;
  final String title;
  final String coverImagePath;
  final String? description;

  @override
  State<HymnBookTile> createState() => _HymnBookTileState();
}

class _HymnBookTileState extends State<HymnBookTile> {
  @override
  Widget build(BuildContext context) {
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      elevation: 2,
      borderRadius: BorderRadius.circular(
        defaultSize * .5,
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            HymnBookPage.routeName,
            arguments: {
              'hymnBookId': widget.hymnBookId,
              'title': widget.title,
            },
          );
        },
        child: GridTile(
          footer: Container(
            width: double.infinity,
            padding: EdgeInsets.all(defaultSize * .2),
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withAlpha(153),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(defaultSize * .5),
                bottomRight: Radius.circular(defaultSize * .5),
              ),
            ),
            height: defaultSize * 2,
            alignment: Alignment.centerLeft,
            child: Text(
              widget.title,
              softWrap: true,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleMedium!.copyWith(
                color: colorScheme.onPrimary,
                fontSize: defaultSize * .7,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(widget.coverImagePath),
                fit: BoxFit.cover,
              ),
              borderRadius: BorderRadius.circular(defaultSize * .5),
            ),
          ),
        ),
      ),
    );
  }
}
