import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

const double size = 16.0;

class SelectIndicator extends StatelessWidget {
  final bool active;
  
  const SelectIndicator({
    super.key,

    required this.active
  });

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Container(
        height: size,
        width: size,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(size/2)
        ),
      );
    }

    Color mainColor = Theme.of(context).primaryColor;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size/2),
        color: mainColor
      ),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Center(
          child: Container(
            height: size,
            width: size,
            decoration: BoxDecoration(
              border: Border.all(
                color: SColors.getBackgroundColor(context),
                width: 1.5
              ),
              borderRadius: BorderRadius.circular(size/2),
              color: mainColor
            ),
          )
        ),
      ),
    );
  }
}