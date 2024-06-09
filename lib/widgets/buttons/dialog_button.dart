import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class DialogButton extends StatefulWidget {
  const DialogButton({
    super.key,

    required this.style,
    required this.text,
    required this.onTap
  });

  final DialogButtonStyle style;
  final String text;
  final Function() onTap;

  @override
  State<DialogButton> createState() => _DialogButtonState();
}

class _DialogButtonState extends State<DialogButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    Color color =
      widget.style == DialogButtonStyle.primary
      ? Theme.of(context).primaryColor
      : Colors.transparent;

    return Expanded(
      child: AnimatedScale(
        scale: _scale, 
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeIn,
        child: Material(
          elevation: widget.style == DialogButtonStyle.primary ? 5.0 : 0.0,
          color: color,
          shadowColor: color.toShadow,
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
              child: Text(
                widget.text,
                style: TextStyle(
                  color: 
                    widget.style == DialogButtonStyle.primary
                    ? Colors.white
                    : SColors.getInvertedGreyscaleColor(context)
                ),
                textAlign: TextAlign.center,
              ),
            )
          )
        )
      ),
    );
  }
}

enum DialogButtonStyle {
  primary,
  secondary
}