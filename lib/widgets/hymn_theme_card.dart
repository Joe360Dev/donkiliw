import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:donkiliw/utils/size_config.dart';
import 'package:donkiliw/pages/theme_details_page.dart';

class HymnThemeCard extends StatelessWidget {
  const HymnThemeCard({
    super.key,
    required this.title,
    this.themeId,
    required this.iconPath,
  });

  final String title;
  final int? themeId;
  final String iconPath;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        defaultSize * 0.3,
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).pushNamed(
            ThemeDetailsPage.routeName,
            arguments: {
              'hymn_theme_id': themeId,
            },
          );
        },
        child: Container(
          padding: EdgeInsets.all(
            defaultSize * .5,
          ),
          width: defaultSize * 8.5,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              defaultSize * .3,
            ),
            color: colorScheme.primary.withAlpha(100),
          ),
          child: Row(
            children: [
              SvgPicture.asset(
                'assets/svg_icons/$iconPath',
                height: defaultSize * 2,
                width: defaultSize * 2,
                colorFilter: ColorFilter.mode(
                  colorScheme.primary,
                  BlendMode.srcIn,
                ),
              ),
              SizedBox(width: defaultSize * .5),
              Expanded(
                child: Text(
                  title,
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium!.copyWith(
                    color: colorScheme.onSurface,
                    fontSize: defaultSize * .8,
                    fontWeight: FontWeight.w500,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
