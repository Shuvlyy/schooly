import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class AppBarLeadingButton extends StatefulWidget {
  final IconData icon;
  final Function() onTap;
  
  const AppBarLeadingButton({
    super.key,

    required this.icon,
    required this.onTap
  });

  @override
  State<AppBarLeadingButton> createState() => _AppBarLeadingButtonState();
}

class _AppBarLeadingButtonState extends State<AppBarLeadingButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color.fromRGBO(123, 56, 131, 1);

    Widget buttonWidget = Padding(
      padding: const EdgeInsets.all(20.0),
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
            borderRadius: BorderRadius.circular(15.0),
            child: Center(
              child: Icon(
                widget.icon,
                color: Colors.white,
                // size: 22.0,
              ),
            ),
          ),
        ),
      ),
    );

    return buttonWidget;
  }
}