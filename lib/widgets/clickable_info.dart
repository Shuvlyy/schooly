import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class ClickableInfo extends StatelessWidget {
  final String title;
  final String subtitle;
  final Function()? onTap;
  
  const ClickableInfo({
    super.key,

    required this.title,
    required this.subtitle,

    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.0),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          children: <Text>[
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: SColors.getInvertedGreyscaleColor(context)
              ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyLarge
            )
          ],
        ),
      )
    );
  }
}