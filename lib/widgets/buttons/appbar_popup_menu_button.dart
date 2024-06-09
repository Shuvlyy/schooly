import 'package:flutter/material.dart';
import 'package:schooly/common/scolors.dart';

class AppbarPopupMenuButton extends StatelessWidget {
  const AppbarPopupMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    Color bgColor = const Color.fromRGBO(123, 56, 131, 1);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Material(
        elevation: 2.0,
        color: bgColor,
        shadowColor: bgColor.toShadow,
        borderRadius: BorderRadius.circular(15.0),
        child: const Padding(
          padding: EdgeInsets.all(10.0),
          child: Center(
            child: Icon(
              Icons.more_vert_rounded,
              color: Colors.white,
            ),
          )
        )
      ),
    );
  }
}