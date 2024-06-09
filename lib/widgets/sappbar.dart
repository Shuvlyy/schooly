import 'package:flutter/material.dart';

const double size = 82.0;

class SAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? leading;
  final Widget? title;
  final List<Widget>? actions;

  const SAppBar({
    super.key,
    
    this.leading,
    this.title,
    this.actions
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: title,
      actions: actions,

      leadingWidth: size,
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(size);
}