import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class AppbarActionButton extends StatefulWidget {
  final String? text;
  final IconData? icon;
  final bool defaultPadding;
  final Function()? onTap;

  const AppbarActionButton({
    super.key,

    this.text,
    this.icon,
    this.defaultPadding = true,
    this.onTap,
  });

  @override
  State<AppbarActionButton> createState() => _AppbarActionButtonState();
}

class _AppbarActionButtonState extends State<AppbarActionButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color.fromRGBO(123, 56, 131, 1);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.defaultPadding ? 20.0 : 0.0),
      child: AnimatedScale(
        scale: _scale, 
        duration: const Duration(milliseconds: 50),
        curve: Curves.easeIn,
        child: Material(
          elevation: 2.0,
          color: bgColor,
          shadowColor: bgColor.toShadow,
          borderRadius: BorderRadius.circular(15.0),
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) {
              setState(() => _scale = 0.95);
            },
            onTapUp: (_) {
              setState(() => _scale = 1);
            },
            onTapCancel: () {
              setState(() => _scale = 1);
            },
            borderRadius: BorderRadius.circular(15.0),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: <Widget>[
                  if (widget.icon != null) ... {
                    Icon(
                      widget.icon,
                      color: Colors.white,
                    )
                  },

                  if (widget.text != null) ... {
                    Text(
                      widget.text!,
                      style: const TextStyle(
                        color: Colors.white
                      ),
                    )
                  }
                ],
              )
            ),
          ),
        ),
      ),
    );
  }
}