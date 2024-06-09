import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class SButton extends StatefulWidget {
  final Color? backgroundColor;
  final IconData? icon;
  final String? title;
  final Function() onTap;
  
  const SButton({
    super.key,

    this.backgroundColor,
    this.icon,
    this.title,
    required this.onTap,
  });

  @override
  State<SButton> createState() => _SButtonState();
}

class _SButtonState extends State<SButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    if (widget.icon == null && widget.title == null) {
      return Container(); // TODO: replace all of this with an assert
    }

    Color? bgColor = widget.backgroundColor ?? Theme.of(context).primaryColor;
    
    Widget buttonWidget = AnimatedScale(
      scale: _scale, 
      duration: const Duration(milliseconds: 50),
      curve: Curves.easeIn,
      child: Material(
        color: bgColor,
        shadowColor: bgColor.toShadow,
        borderRadius: BorderRadius.circular(20.0),
        child: InkWell(
          onTap: () => widget.onTap(),
          onTapDown: (_) {
            setState(() => _scale = 0.95);
          },
          onTapUp: (_) {
            setState(() => _scale = 1);
          },
          onTapCancel: () {
            setState(() => _scale = 1);
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (widget.icon != null) ... {
                    Icon(
                      widget.icon,
                      color: Colors.white,
                      // size: 22.0,
                    ),
                  },
                  if (widget.title != null) ... {
                    const SizedBox(width: 10.0),
                    Text(
                      widget.title!,
                      style: const TextStyle(
                        color: Colors.white
                      ),
                    )
                  }
                ],
              ),
            )
          ),
        ),
      )
    );

    return buttonWidget;
  }
}

// class SButtonType {
//   static const double small = 12.0;
//   static const double normal = 24.0;
//   static const double big = 28.0;
// }