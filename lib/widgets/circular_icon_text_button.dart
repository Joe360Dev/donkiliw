import 'package:flutter/material.dart';
import 'package:donkiliw/utils/size_config.dart';

class CircularIconTextButton extends StatelessWidget {
  const CircularIconTextButton({
    super.key,
    required this.icon,
    required this.title,
    this.onPressed,
  });
  final IconData icon;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(
        defaultSize,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: defaultSize * .5,
          horizontal: defaultSize,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: defaultSize * 2,
            ),
            SizedBox(height: defaultSize * .25),
            Text(
              title,
              style: TextStyle(
                fontSize: defaultSize * .75,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
