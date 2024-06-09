import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class ClickableTile extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final IconData? trailingIcon;
  final Color? trailingIconColor;
  final String title;
  final String? subtitle;
  final bool isTitleMain;

  final Function()? onTap;

  const ClickableTile({
    super.key,

    required this.icon,
    this.iconBackgroundColor = Colors.grey,
    this.trailingIcon = Icons.arrow_forward_ios_rounded,
    this.trailingIconColor,
    required this.title,
    this.subtitle,
    this.isTitleMain = true,

    this.onTap
  });

  @override
  Widget build(BuildContext context) {
    final TextStyle titleTextStyle = 
      Theme.of(context).textTheme.bodyLarge!;
    
    final TextStyle subtitleTextStyle =
      Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: SColors.getInvertedGreyscaleColor(context)
      );

    return Material(
      color: SColors.getBackgroundColor(context),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15.0),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Flex(
            direction: Axis.horizontal,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      blurRadius: 4.0,
                      color: iconBackgroundColor,
                    )
                  ]
                ),
                padding: const EdgeInsets.all(7.5),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 26.0,
                ),
              ),
    
              const SizedBox(width: 15.0),
    
              if (subtitle != null) ... {
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: isTitleMain ? titleTextStyle : subtitleTextStyle
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        subtitle!,
                        style: isTitleMain ? subtitleTextStyle : titleTextStyle,
                      )
                    ],
                  ),
                )
              } else ... {
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge
                  ),
                )
              },
    
              const SizedBox(width: 20.0),

              if (onTap != null) ... {
                Icon(
                  trailingIcon ?? Icons.arrow_forward_ios_rounded,
                  size: 26.0,
                  color: trailingIconColor,
                )
              }
            ],
          ),
        ),
      ),
    );
  }
}