import 'package:flutter/material.dart';
import 'package:hymns/utils/size_config.dart';

class CircularColorChoiceChip extends StatelessWidget {
  const CircularColorChoiceChip({
    super.key,
    required this.color,
    required this.isSelected,
    this.onSelected,
  });
  final bool isSelected;
  final Color color;
  final void Function(bool)? onSelected;

  @override
  Widget build(BuildContext context) {
    SizeConfig.init(context);
    final defaultSize = SizeConfig.defaultSize;

    return ChoiceChip(
      onSelected: onSelected,
      selected: isSelected,
      showCheckmark: false,
      labelPadding: EdgeInsets.zero,
      padding: EdgeInsets.all(.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(
          defaultSize,
        ),
        side: BorderSide(
          color: isSelected ? color : Colors.grey,
          width: 1,
        ),
      ),
      label: CircleAvatar(
        backgroundColor: color,
        radius: defaultSize,
        child: isSelected
            ? Icon(
                Icons.check,
                size: defaultSize,
                color: ThemeData(
                  colorScheme: ColorScheme.fromSeed(
                    seedColor: color,
                  ),
                ).colorScheme.onPrimary,
              )
            : null,
      ),
    );
  }
}
