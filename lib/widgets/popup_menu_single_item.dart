import 'package:flutter/material.dart';

class PopupMenuSingleItem extends StatelessWidget {
  final String text;
  final IconData icon;

  const PopupMenuSingleItem({
    super.key,

    required this.text,
    required this.icon
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: Theme.of(context).textTheme.titleLarge?.color,
        ),
        const SizedBox(width: 10.0),
        Text(
          text
        )
      ],
    );
  }
}